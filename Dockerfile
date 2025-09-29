FROM ubuntu:24.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install apt-fast, add repositories, and install dependencies
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository ppa:apt-fast/stable -y \
    && add-apt-repository ppa:ondrej/php -y \
    && apt-get update \
    && apt-get install -y apt-fast \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && echo 'apt-fast apt-fast/maxdownloads string 10' | debconf-set-selections \
    && echo 'apt-fast apt-fast/dlflag boolean true' | debconf-set-selections \
    && echo 'apt-fast apt-fast/aptmanager string apt-get' | debconf-set-selections \
    && apt-fast install -y \
    libpcre2-dev \
    zlib1g-dev \
    git \
    cmake \
    ninja-build \
    pkg-config \
    clang \
    libc++-dev \
    libc++abi-dev \
    mold \
    ccache \
    python3 \
    python3-jsonschema \
    python3-jinja2 \
    php8.4-fpm \
    php8.4-cli \
    nginx \
    systemd \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set up Clang as default compiler
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100

# Configure ccache
RUN ccache --set-config=max_size=2G \
    && ccache --set-config=compression=true \
    && ccache --set-config=cache_dir=/var/cache/ccache \
    && mkdir -p /var/cache/ccache \
    && chmod 777 /var/cache/ccache

# Set up ccache wrapper symlinks
RUN mkdir -p /usr/lib/ccache \
    && ln -sf /usr/bin/ccache /usr/lib/ccache/clang \
    && ln -sf /usr/bin/ccache /usr/lib/ccache/clang++ \
    && ln -sf /usr/bin/ccache /usr/lib/ccache/gcc \
    && ln -sf /usr/bin/ccache /usr/lib/ccache/g++

# Add ccache to PATH and set environment variables
ENV PATH="/usr/lib/ccache:$PATH"
ENV CCACHE_DIR=/var/cache/ccache
ENV CCACHE_COMPRESS=1
ENV CCACHE_MAXSIZE=2G

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Create application directory structure
WORKDIR /app

# Clone Bedrock as a sibling to server
RUN git clone https://github.com/Expensify/Bedrock.git

# Build Bedrock with Clang and ccache
WORKDIR /app/Bedrock
ENV CC=clang
ENV CXX=clang++
RUN --mount=type=cache,target=/var/cache/ccache \
    make --jobs $(nproc) && touch bedrock.db

# Create server directory structure
WORKDIR /app
RUN mkdir -p server/api server/core server/core/commands

# Copy project files
COPY server/ server/

# Build the Core plugin
WORKDIR /app/server/core
RUN --mount=type=cache,target=/var/cache/ccache \
    cmake -G Ninja . && ninja -j $(nproc)

# Setup systemd
RUN systemctl enable nginx
RUN systemctl enable php8.4-fpm

# Expose ports
EXPOSE 80 8888

# Copy startup script and service files
COPY start.sh /app/start.sh
COPY bedrock.service /app/bedrock.service
RUN chmod +x /app/start.sh

# Start services
CMD ["/app/start.sh"]

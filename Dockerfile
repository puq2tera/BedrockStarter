FROM ubuntu:24.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre++-dev \
    zlib1g-dev \
    git \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# Create bedrock user and directory
RUN useradd -m -s /bin/bash bedrock
USER bedrock
WORKDIR /home/bedrock

# Clone and build Bedrock
RUN git clone https://github.com/Expensify/Bedrock.git
WORKDIR /home/bedrock/Bedrock

# Build Bedrock
RUN make

# Create empty database
RUN touch bedrock.db

# Expose the default Bedrock port
EXPOSE 8888

# Start Bedrock
CMD ["./bedrock"]

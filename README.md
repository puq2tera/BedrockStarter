# Bedrock Starter

A minimal Docker-based starter project for [Bedrock](https://bedrockdb.com/), the rock-solid distributed database built by Expensify.

## What is Bedrock?

Bedrock is a simple, modular, WAN-replicated, blockchain-based data foundation for global-scale applications. It's built on top of SQLite and provides:

- **Fast** - Direct memory access to SQLite with distributed read scaling
- **Simple** - Modern defaults that "just work" 
- **Reliable** - Active/active distributed transactions with automatic failover
- **Powerful** - Full SQLite feature set plus plugin system with job queue and cache

## Project Structure

This starter project provides a complete development environment with:

```
/app/
├── Bedrock/                    # Official Bedrock database (cloned from GitHub)
│   ├── bedrock                 # Compiled Bedrock binary
│   └── bedrock.db             # SQLite database file
└── server/                     # Your application code
    ├── api/                    # PHP REST API server
    │   ├── composer.json       # PHP dependencies
    │   ├── api.php            # Simple REST API endpoints
    │   └── nginx.conf         # Nginx configuration
    └── core/                   # C++ Bedrock plugin
        ├── Core.h/.cpp        # Main plugin class (extends BedrockPlugin)
        ├── commands/          # Custom Bedrock commands
        │   └── HelloWorld.h/.cpp  # Example command (extends BedrockCommand)
        └── CMakeLists.txt     # C++ build configuration
```

## Server Services

The container runs multiple services managed by systemd:

### 🔧 **Bedrock Database** (Port 8888)
- **Service**: `bedrock.service`
- **Plugin**: Custom `Core` plugin with `HelloWorld` command
- **Database**: SQLite with full Bedrock features
- **Access**: Direct socket connection or MySQL protocol

### 🌐 **PHP API Server** (Port 80)
- **Service**: `nginx` + `php8.4-fpm`
- **Framework**: Simple PHP 8.4 REST API
- **Endpoints**:
  - `GET /api/status` - Service health check
  - `GET /api/hello?name=World` - Hello world endpoint
- **Features**: JSON responses, CORS headers, error handling

### ⚙️ **Build System**
- **C++ Compiler**: Clang with libc++ (C++20, matches Bedrock)
- **Linker**: mold (ultra-fast linking)
- **Build Tool**: CMake + Ninja
- **Package Manager**: apt-fast (parallel downloads)
- **Compiler Cache**: ccache (2GB, compressed)
- **Features**: LTO, sanitizers, modern optimizations

## Quick Start

### Using Docker Compose

1. **Start the development environment:**
   ```bash
   docker compose up --build
   ```

2. **Test the API:**
   ```bash
   curl http://localhost/api/status
   curl http://localhost/api/hello?name=Developer
   ```

3. **Test Bedrock:**
   ```bash
   # Basic SQL
   nc localhost 8888
   Query: SELECT 1 AS hello, 'world' AS bedrock;
   
   # Custom plugin command
   nc localhost 8888
   HelloWorld name=Developer
   ```

4. **Stop services:**
   ```bash
   docker compose down
   ```

### 3-Node Cluster Setup

For production-like distributed setup:

1. **Uncomment nodes 2 and 3** in `docker-compose.yml`

2. **Start the cluster:**
   ```bash
   docker compose up --build
   ```

3. **Access different nodes:**
   ```bash
   # Node 1 (Primary)
   curl http://localhost/api/status
   nc localhost 8888
   
   # Node 2 (Follower)  
   curl http://localhost:81/api/status
   nc localhost 8889
   
   # Node 3 (Follower)
   curl http://localhost:82/api/status  
   nc localhost 8890
   ```

### Example Queries

**Basic SQL:**
```sql
Query: CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);
Query: INSERT INTO users (name) VALUES ('Alice'), ('Bob');
Query: SELECT * FROM users;
```

**JSON Output:**
```
Query
query: SELECT * FROM users;
format: json
```

**Using MySQL client:**
```bash
mysql -h 127.0.0.1 -P 8888
```

## Development

### Adding New API Endpoints

Edit `server/api/api.php` to add new REST endpoints:

```php
case '/api/myendpoint':
    handleMyEndpoint();
    break;
```

### Creating New Bedrock Commands

1. Create a new command class in `server/core/commands/`:
   ```cpp
   class MyCommand : public BedrockCommand {
       // Implement peekCommand() and processCommand()
   };
   ```

2. Register it in `server/core/Core.cpp`:
   ```cpp
   registerCommand(new MyCommand(*this));
   ```

3. Rebuild the plugin:
   ```bash
   # Using docker compose (recommended)
   docker compose build
   docker compose restart
   
   # Or rebuild within running container
   docker compose exec bedrock-node1 bash
   cd /app/server/core
   ninja
   systemctl restart bedrock
   ```

### Service Management

**Docker Compose Commands:**
```bash
# View logs
docker compose logs -f
docker compose logs -f bedrock-node1

# Check service status
docker compose ps
docker compose exec bedrock-node1 systemctl status bedrock

# Restart services
docker compose restart
docker compose restart bedrock-node1

# Scale cluster (after uncommenting nodes)
docker compose up --scale bedrock-node2=1 --scale bedrock-node3=1
```

**Within Container:**
```bash
# Check service status
systemctl status bedrock
systemctl status nginx
systemctl status php8.4-fpm

# View logs
journalctl -u bedrock -f
tail -f /var/log/nginx/api_access.log
```

### Build Configuration

The C++ build system uses cutting-edge tooling for maximum performance:

**Compilation Speed:**
- **apt-fast**: Parallel package downloads (up to 10x faster)
- **ccache**: Compiler caching (2GB compressed cache)
- **Clang**: Modern C++20 compiler with libc++ (matches Bedrock)
- **mold linker**: Ultra-fast linking (5-10x faster than gold/bfd)

**Build Modes:**
- **Debug builds**: AddressSanitizer + UndefinedBehaviorSanitizer
- **Release builds**: Link-time optimization (LTO) for maximum performance
- **Development**: Live code reloading with Docker volumes

**Performance Benefits:**
- **First build**: Standard compile time, populates caches
- **Subsequent builds**: Near-instant with ccache hits
- **Docker rebuilds**: Persistent caches across container rebuilds

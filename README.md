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
- **C++ Compiler**: Clang 18 (latest LTS)
- **C++ Standard**: C++23 with libc++
- **Linker**: mold (ultra-fast linking)
- **Build Tool**: CMake + Ninja
- **Features**: LTO, sanitizers, modern optimizations

## Quick Start

### Using Docker

1. **Build the container:**
   ```bash
   docker build -t bedrock-starter .
   ```

2. **Run all services:**
   ```bash
   docker run -p 80:80 -p 8888:8888 bedrock-starter
   ```

3. **Test the API:**
   ```bash
   curl http://localhost/api/status
   curl http://localhost/api/hello?name=Developer
   ```

4. **Test Bedrock:**
   ```bash
   # Basic SQL
   nc localhost 8888
   Query: SELECT 1 AS hello, 'world' AS bedrock;
   
   # Custom plugin command
   nc localhost 8888
   HelloWorld name=Developer
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
   docker exec -it <container> bash
   cd /app/server/core
   ninja
   systemctl restart bedrock
   ```

### Service Management

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

The C++ build system uses modern tooling:
- **Fast compilation**: Clang 18 with optimized flags
- **Fast linking**: mold linker (5-10x faster than traditional linkers)
- **Debug builds**: AddressSanitizer + UndefinedBehaviorSanitizer
- **Release builds**: Link-time optimization (LTO) for maximum performance

# Bedrock Starter

A minimal Docker-based starter project for [Bedrock](https://bedrockdb.com/), the rock-solid distributed database built by Expensify.

## What is Bedrock?

Bedrock is a simple, modular, WAN-replicated, blockchain-based data foundation for global-scale applications. It's built on top of SQLite and provides:

- **Fast** - Direct memory access to SQLite with distributed read scaling
- **Simple** - Modern defaults that "just work" 
- **Reliable** - Active/active distributed transactions with automatic failover
- **Powerful** - Full SQLite feature set plus plugin system with job queue and cache

## Quick Start

### Using Docker

1. **Build the container:**
   ```bash
   docker build -t bedrock-starter .
   ```

2. **Run Bedrock:**
   ```bash
   docker run -p 8888:8888 bedrock-starter
   ```

3. **Test the connection:**
   ```bash
   # In another terminal
   nc localhost 8888
   ```
   
   Then type:
   ```
   Query: SELECT 1 AS hello, 'world' AS bedrock;
   ```
   
   Press Enter twice to execute.

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

## What's Next?

- Explore [Bedrock plugins](https://bedrockdb.com/) (Jobs, Cache, etc.)
- Set up multi-node clustering
- Build custom plugins for your application
- Deploy across multiple datacenters

## Resources

- [Official Documentation](https://bedrockdb.com/)
- [GitHub Repository](https://github.com/Expensify/Bedrock)
- [Why Bedrock?](http://firstround.com/review/your-database-is-your-prison-heres-how-expensify-broke-free/)

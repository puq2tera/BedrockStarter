#!/bin/bash
set -e

echo "Starting Bedrock with Core plugin..."

# Create database file in data directory if it doesn't exist
if [ ! -f /app/data/bedrock.db ]; then
    echo "Creating initial database..."
    touch /app/data/bedrock.db
fi

# Start Bedrock with Core plugin
cd /app/Bedrock
exec ./bedrock -db /app/data/bedrock.db -plugins Core -pluginDir /app/server/core/lib

#include "HelloWorld.h"
#include "../Core.h"

// Static member definitions
const string HelloWorld::_name = "HelloWorld";
const string HelloWorld::_description = "A simple hello world command for the Core plugin";

HelloWorld::HelloWorld(SQLiteCommand&& baseCommand, Core* plugin) 
    : BedrockCommand(std::move(baseCommand), plugin) {
    // Initialize the command
}

HelloWorld::~HelloWorld() {
    // Cleanup
}

bool HelloWorld::peek(SQLite& db) {
    // This command doesn't need to peek at the database
    // Return false to indicate we don't need to peek
    return false;
}

void HelloWorld::process(SQLite& db) {
    // Get the name parameter, default to "World"
    string name = request["name"];
    if (name.empty()) {
        name = "World";
    }
    
    // Create response
    response["message"] = "Hello, " + name + "!";
    response["from"] = "Bedrock Core Plugin";
    response["timestamp"] = STimeNow();
    response["plugin_name"] = _plugin->getName();
    response["plugin_version"] = static_cast<Core*>(_plugin)->getVersion();
    
    SINFO("HelloWorld command executed for: " << name);
}

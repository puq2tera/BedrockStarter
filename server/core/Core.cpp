#include "Core.h"
#include "commands/HelloWorld.h"

// Static member definitions
const string Core::_name = "Core";
const string Core::_version = "1.0.0";

Core::Core(BedrockServer& s) : BedrockPlugin(s) {
    // Initialize the plugin
}

Core::~Core() {
    // Cleanup
}

unique_ptr<BedrockCommand> Core::getCommand(SQLiteCommand&& baseCommand) {
    // Check if this is a command we handle
    if (SIEquals(baseCommand.request.methodLine, "HelloWorld")) {
        return make_unique<HelloWorld>(std::move(baseCommand), this);
    }
    
    // Not our command
    return nullptr;
}

const string& Core::getName() const {
    return _name;
}

const string& Core::getVersion() const {
    return _version;
}

// Plugin factory function (required by Bedrock)
extern "C" BedrockPlugin* createPlugin(BedrockServer& server) {
    return new Core(server);
}

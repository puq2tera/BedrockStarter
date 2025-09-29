#pragma once
#include <libstuff/libstuff.h>
#include <BedrockCommand.h>

// Forward declaration
class BedrockPlugin_Core;

class HelloWorld : public BedrockCommand {
public:
    // Constructor
    HelloWorld(SQLiteCommand&& baseCommand, BedrockPlugin_Core* plugin);
    
    // Destructor
    virtual ~HelloWorld();
    
    // Command execution - override the base class methods
    virtual bool peek(SQLite& db) override;
    virtual void process(SQLite& db) override;
    
private:
    static const string _name;
    static const string _description;
};

#pragma once
#include <libstuff/libstuff.h>
#include <BedrockPlugin.h>

class Core : public BedrockPlugin {
public:
    // Constructor
    Core(BedrockServer& s);
    
    // Destructor
    virtual ~Core();
    
    // Required: Create command from SQLiteCommand
    virtual unique_ptr<BedrockCommand> getCommand(SQLiteCommand&& baseCommand) override;
    
    // Plugin name
    virtual const string& getName() const override;
    
    // Plugin version (not an override - plugins don't have getVersion in base class)
    virtual const string& getVersion() const;
    
private:
    static const string _name;
    static const string _version;
};

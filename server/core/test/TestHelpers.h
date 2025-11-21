#pragma once

#include <libstuff/libstuff.h>
#include <test/lib/BedrockTester.h>

#ifndef CORE_TEST_PLUGIN_DIR
#    error "CORE_TEST_PLUGIN_DIR must be defined"
#endif

#ifndef CORE_TEST_BEDROCK_BIN
#    error "CORE_TEST_BEDROCK_BIN must be defined"
#endif

class TestHelpers {
public:
    /**
     * Create a BedrockTester instance configured for Core plugin tests
     */
    static BedrockTester createTester() {
        const string corePluginPath = string(CORE_TEST_PLUGIN_DIR) + "/Core.so";
        map<string, string> args = {
            {"-plugins", "DB," + corePluginPath},
            {"-db", BedrockTester::getTempFileName("coretest")}
        };

        return {args, {}, 0, 0, 0, true, CORE_TEST_BEDROCK_BIN};
    }
};


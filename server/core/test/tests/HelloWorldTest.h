#pragma once

#include "../TestHelpers.h"
#include <libstuff/SData.h>

struct HelloWorldTest : tpunit::TestFixture {
    HelloWorldTest()
        : tpunit::TestFixture(
            "HelloWorldTests",
            TEST(HelloWorldTest::testHelloWithName),
            TEST(HelloWorldTest::testHelloDefault)
        ) { }

    void testHelloWithName() {
        BedrockTester tester = TestHelpers::createTester();

        SData request("HelloWorld");
        request["name"] = "TestUser";
        vector<SData> responses = tester.executeWaitMultipleData({request}, 1);
        SData& response = responses.front();
        
        ASSERT_TRUE(SStartsWith(response.methodLine, "200 OK"));
        ASSERT_EQUAL(response["message"], "Hello, TestUser!");
        ASSERT_EQUAL(response["from"], "Bedrock Core Plugin");
        ASSERT_EQUAL(response["plugin_name"], "Core");
        ASSERT_EQUAL(response["plugin_version"], "1.1.0");
    }

    void testHelloDefault() {
        BedrockTester tester = TestHelpers::createTester();

        SData request("HelloWorld");
        vector<SData> responses = tester.executeWaitMultipleData({request}, 1);
        SData& response = responses.front();
        
        ASSERT_TRUE(SStartsWith(response.methodLine, "200 OK"));
        ASSERT_EQUAL(response["message"], "Hello, World!");
    }
};


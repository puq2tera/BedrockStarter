#pragma once

#include "../TestHelpers.h"
#include <libstuff/SData.h>

struct MessagesTest : tpunit::TestFixture {
    MessagesTest()
        : tpunit::TestFixture(
            "MessagesTests",
            TEST(MessagesTest::testCreateAndGet)
        ) { }

    void testCreateAndGet() {
        BedrockTester tester = TestHelpers::createTester();

        const string messageText = "Integration test " + SToStr(STimeNow());

        // Create a message
        SData createRequest("CreateMessage");
        createRequest["name"] = "Tester";
        createRequest["message"] = messageText;
        SData createResponse = tester.executeWaitMultipleData({createRequest}, 1).front();
        
        ASSERT_TRUE(SStartsWith(createResponse.methodLine, "200 OK"));
        ASSERT_EQUAL(createResponse["result"], "stored");
        ASSERT_EQUAL(createResponse["message"], messageText);
        const string messageID = createResponse["messageID"];
        ASSERT_FALSE(messageID.empty());

        // Fetch messages and ensure the inserted message is present
        SData listRequest("GetMessages");
        listRequest["limit"] = "10";
        SData listResponse = tester.executeWaitMultipleData({listRequest}, 1).front();
        
        ASSERT_TRUE(SStartsWith(listResponse.methodLine, "200 OK"));
        ASSERT_FALSE(listResponse["messages"].empty());

        list<string> rows = SParseJSONArray(listResponse["messages"]);
        bool found = false;
        for (const string& row : rows) {
            const STable entry = SParseJSONObject(row);
            if (entry.at("messageID") == messageID) {
                ASSERT_EQUAL(entry.at("name"), "Tester");
                ASSERT_EQUAL(entry.at("message"), messageText);
                found = true;
                break;
            }
        }

        ASSERT_TRUE(found);
    }
};


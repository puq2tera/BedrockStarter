# Core Plugin Tests

Basic test suite for the Bedrock Core plugin.

## Building and Running

Use the helper script:

```bash
./scripts/test-cpp.sh
```

Pass arguments (for example, to run a specific test):

```bash
./scripts/test-cpp.sh -only testHelloWithName
./scripts/test-cpp.sh -only testCreateAndGet
```

Enable verbose logging:

```bash
./scripts/test-cpp.sh -v
```

## Test Structure

- `main.cpp` - Test runner entry point
- `TestHelpers.h` - Common test utilities and tester creation
- `tests/` - Individual test files per command/feature
  - `HelloWorldTest.h` - Tests for HelloWorld command
  - `MessagesTest.h` - Tests for CreateMessage/GetMessages commands
- `CMakeLists.txt` - Build configuration

## Adding Tests

1. Create a new test file in `tests/` (e.g., `MyCommandTest.h`):

```cpp
#pragma once
#include "../TestHelpers.h"

struct MyCommandTest : tpunit::TestFixture {
    MyCommandTest()
        : tpunit::TestFixture(
            "MyCommandTests",
            TEST(MyCommandTest::testBasicFunctionality)
        ) { }

    void testBasicFunctionality() {
        BedrockTester tester = TestHelpers::createTester();
        
        SData request("MyCommand");
        request["param"] = "value";
        SData response = tester.executeWaitMultipleData({request}, 1).front();
        
        ASSERT_TRUE(SStartsWith(response.methodLine, "200 OK"));
        ASSERT_EQUAL(response["result"], "expected");
    }
};
```

2. Include it in `main.cpp`:

```cpp
#include "tests/MyCommandTest.h"

int main(int argc, char* argv[]) {
    // ...
    MyCommandTest myCommandTest;
    // ...
}
```


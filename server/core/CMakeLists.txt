cmake_minimum_required(VERSION 3.16)
project(BedrockCore)

# Force use of Clang
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)

# Set C++ standard to C++23
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Use mold linker for faster linking
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=mold")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -fuse-ld=mold")

# Enable modern C++ features and optimizations
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -Wall -Wextra -Wpedantic")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -DNDEBUG -flto")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0 -g -fsanitize=address -fsanitize=undefined")

# Find required packages
find_package(PkgConfig REQUIRED)

# Set include directories
include_directories(/app/Bedrock)
include_directories(/app/Bedrock/libstuff)

# Add source files
set(SOURCES
    Core.cpp
    commands/HelloWorld.cpp
)

# Create shared library for the plugin
add_library(BedrockCore SHARED ${SOURCES})

# Link libraries (you may need to adjust these based on Bedrock's actual linking requirements)
target_link_libraries(BedrockCore
    pthread
    pcre
    z
    c++
    c++abi
)

# Set output directory
set_target_properties(BedrockCore PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

# Install target
install(TARGETS BedrockCore
    LIBRARY DESTINATION /app/server/core/lib
)

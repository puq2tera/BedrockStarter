#!/bin/bash
# Run clang-tidy on Core plugin C++ code

set -e

# shellcheck source=scripts/common.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

PROJECT_DIR=$(get_project_dir)
readonly PROJECT_DIR

CORE_DIR="${PROJECT_DIR}/server/core"
readonly CORE_DIR

print_header "Clang-Tidy"

# Check if clang-tidy is installed
if ! command -v clang-tidy &> /dev/null; then
    error "clang-tidy is not installed"
    echo
    echo "Install it with:"
    echo "  brew install llvm          # macOS"
    echo "  sudo apt install clang-tidy # Ubuntu/Debian"
    exit 1
fi

CLANG_TIDY_VERSION=$(clang-tidy --version | head -n1)
info "Using: ${CLANG_TIDY_VERSION}"

# Ensure we have compile_commands.json
BUILD_DIR="${CORE_DIR}/.build"
mkdir -p "${BUILD_DIR}"
if [[ ! -f "${BUILD_DIR}/compile_commands.json" ]]; then
    info "compile_commands.json not found, generating..."
    cd "${BUILD_DIR}"
    cmake -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
fi

# Run clang-tidy on Core plugin source files (including tests and headers)
info "Running clang-tidy on Core plugin (sources + tests + headers)..."
echo

# Find all .cpp files in the core directory (including tests)
CPP_FILES=$(find "${CORE_DIR}" -name "*.cpp" \
    -not -path "*/CMakeFiles/*" \
    -not -path "*/bedrock-starter/Bedrock/test/lib/*")

# Find header files that should be linted independently (test headers not in compilation DB)
HEADER_FILES=$(find "${CORE_DIR}/test/tests" -name "*.h" 2>/dev/null || echo "")
HEADER_FILES="${HEADER_FILES} $(find "${CORE_DIR}/test" -maxdepth 1 -name "TestHelpers.h" 2>/dev/null || echo "")"

# Only report issues in our core sources (ignore ../../Bedrock headers)
HEADER_FILTER="${CORE_DIR}/[^.].*"

if [[ -z "${CPP_FILES}" ]] && [[ -z "${HEADER_FILES}" ]]; then
    warn "No files found to analyze"
    exit 0
fi

# Run clang-tidy on source files
FAILED=0
for file in ${CPP_FILES}; do
    RELATIVE_FILE="${file#"${PROJECT_DIR}"/}"
    info "Checking ${RELATIVE_FILE}..."
    if ! clang-tidy -header-filter="${HEADER_FILTER}" -p "${BUILD_DIR}" "${file}"; then
        FAILED=1
    fi
done

# Run clang-tidy on test header files (using main.cpp as compilation context)
# Note: Test headers aren't in compile_commands.json, so we analyze them via main.cpp
MAIN_CPP="${CORE_DIR}/test/main.cpp"
if [[ -n "${HEADER_FILES}" ]] && [[ -f "${MAIN_CPP}" ]]; then
    for file in ${HEADER_FILES}; do
        if [[ -f "${file}" ]]; then
            RELATIVE_FILE="${file#"${PROJECT_DIR}"/}"
            info "Running clang-tidy on ${RELATIVE_FILE}..."
            # Use same config as main clang-tidy run (respects .clang-tidy file)
            OUTPUT=$(clang-tidy -header-filter=".*${file}.*" -p "${BUILD_DIR}" "${MAIN_CPP}" 2>&1 | grep -E "^${file}:" || true)
            if [[ -n "${OUTPUT}" ]]; then
                echo "${OUTPUT}"
                FAILED=1
            fi
        fi
    done
fi

echo
if [[ ${FAILED} -eq 0 ]]; then
    success "Clang-tidy checks passed!"
else
    error "Clang-tidy found issues"
    exit 1
fi


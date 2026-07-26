#!/usr/bin/env bash

set -euo pipefail

readonly PROJECT_ROOT="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1
    pwd
)"

cd "${PROJECT_ROOT}"

printf '%s\n' '=== ProcLens local verification ==='

printf '\n%s\n' '=== Formatting ==='
mapfile -d '' cpp_files < <(
    find include src tests tools \
        -type f \
        \( -name '*.cpp' -o -name '*.hpp' \) \
        -print0 |
        sort -z
)

if [[ ${#cpp_files[@]} -eq 0 ]]; then
    printf '%s\n' 'ERROR: No C++ source files were found.' >&2
    exit 1
fi

clang-format --dry-run --Werror "${cpp_files[@]}"

readonly presets=(
    debug-clang
    release-clang
    debug-gcc
    release-gcc
    sanitize-clang
    analyze-clang
)

for preset in "${presets[@]}"; do
    printf '\n=== Configure: %s ===\n' "${preset}"
    cmake --preset "${preset}"

    printf '\n=== Build: %s ===\n' "${preset}"
    cmake --build --preset "${preset}"

    printf '\n=== Test: %s ===\n' "${preset}"
    ctest --preset "${preset}"
done

printf '\n%s\n' '=== CLI smoke execution ==='
./build/debug-clang/proclens

printf '\n%s\n' '=== Verification complete ==='
printf '%s\n' 'All required local Milestone 0 checks passed.'

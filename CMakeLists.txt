cmake_minimum_required(VERSION 3.25)

project(
    ProcLens
    VERSION 0.1.0
    DESCRIPTION "Linux process and virtual-memory exploration tool"
    LANGUAGES CXX
)

include(CTest)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(CompilerWarnings)
include(Sanitizers)
include(StaticAnalysis)

option(PROCLENS_WARNINGS_AS_ERRORS
       "Treat compiler warnings as errors"
       OFF)

option(PROCLENS_ENABLE_ADDRESS_SANITIZER
       "Enable AddressSanitizer"
       OFF)

option(PROCLENS_ENABLE_UNDEFINED_SANITIZER
       "Enable UndefinedBehaviorSanitizer"
       OFF)

option(PROCLENS_ENABLE_THREAD_SANITIZER
       "Enable ThreadSanitizer"
       OFF)

option(PROCLENS_ENABLE_CLANG_TIDY
       "Enable clang-tidy"
       OFF)

option(PROCLENS_ENABLE_CPPCHECK
       "Enable Cppcheck"
       OFF)

option(PROCLENS_BUILD_TESTS
       "Build ProcLens tests"
       ON)

add_library(proclens_core
    src/version.cpp
)

add_library(ProcLens::core ALIAS proclens_core)

target_compile_features(proclens_core
    PUBLIC
        cxx_std_20
)

target_include_directories(proclens_core
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

proclens_set_project_warnings(proclens_core)

proclens_enable_sanitizers(proclens_core)

proclens_enable_clang_tidy(proclens_core)

proclens_enable_cppcheck(proclens_core)

add_executable(proclens
    tools/proclens/main.cpp
)

target_link_libraries(proclens
    PRIVATE
        ProcLens::core
)

proclens_set_project_warnings(proclens)

proclens_enable_sanitizers(proclens)

proclens_enable_clang_tidy(proclens)

proclens_enable_cppcheck(proclens)

if(PROCLENS_BUILD_TESTS)
    add_executable(proclens_smoke_tests
        tests/unit/version_smoke_test.cpp
    )

    target_link_libraries(proclens_smoke_tests
        PRIVATE
            ProcLens::core
    )

    proclens_set_project_warnings(proclens_smoke_tests)

    proclens_enable_sanitizers(proclens_smoke_tests)

    proclens_enable_clang_tidy(proclens_smoke_tests)

    proclens_enable_cppcheck(proclens_smoke_tests)

    add_test(
        NAME proclens.version_smoke
        COMMAND proclens_smoke_tests
    )

    set_tests_properties(
        proclens.version_smoke
        PROPERTIES
            LABELS "unit;smoke"
    )
endif()

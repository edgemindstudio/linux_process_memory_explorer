function(proclens_enable_clang_tidy target_name)
    if(NOT TARGET "${target_name}")
        message(FATAL_ERROR
            "proclens_enable_clang_tidy received unknown target: ${target_name}"
        )
    endif()

    if(NOT PROCLENS_ENABLE_CLANG_TIDY)
        return()
    endif()

    find_program(PROCLENS_CLANG_TIDY_EXECUTABLE NAMES clang-tidy)

    if(NOT PROCLENS_CLANG_TIDY_EXECUTABLE)
        message(FATAL_ERROR
            "PROCLENS_ENABLE_CLANG_TIDY is ON, but clang-tidy was not found"
        )
    endif()

    set_target_properties(
        "${target_name}"
        PROPERTIES
            CXX_CLANG_TIDY "${PROCLENS_CLANG_TIDY_EXECUTABLE}"
    )
endfunction()

function(proclens_enable_cppcheck target_name)
    if(NOT TARGET "${target_name}")
        message(FATAL_ERROR
            "proclens_enable_cppcheck received unknown target: ${target_name}"
        )
    endif()

    if(NOT PROCLENS_ENABLE_CPPCHECK)
        return()
    endif()

    find_program(PROCLENS_CPPCHECK_EXECUTABLE NAMES cppcheck)

    if(NOT PROCLENS_CPPCHECK_EXECUTABLE)
        message(FATAL_ERROR
            "PROCLENS_ENABLE_CPPCHECK is ON, but Cppcheck was not found"
        )
    endif()

    set(cppcheck_command
        "${PROCLENS_CPPCHECK_EXECUTABLE}"
        --enable=warning,style,performance,portability
        --inline-suppr
        --suppress=missingIncludeSystem
        --error-exitcode=2
    )

    set_target_properties(
        "${target_name}"
        PROPERTIES
            CXX_CPPCHECK "${cppcheck_command}"
    )
endfunction()

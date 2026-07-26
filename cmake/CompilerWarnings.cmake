function(proclens_set_project_warnings target_name)
    if(NOT TARGET "${target_name}")
        message(FATAL_ERROR
            "proclens_set_project_warnings received unknown target: ${target_name}"
        )
    endif()

    set(clang_and_gcc_warnings
        -Wall
        -Wextra
        -Wpedantic
        -Wconversion
        -Wsign-conversion
        -Wshadow
        -Wnon-virtual-dtor
        -Wold-style-cast
        -Woverloaded-virtual
        -Wnull-dereference
        -Wdouble-promotion
        -Wformat=2
    )

    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
        target_compile_options(
            "${target_name}"
            PRIVATE
                ${clang_and_gcc_warnings}
        )

        if(PROCLENS_WARNINGS_AS_ERRORS)
            target_compile_options(
                "${target_name}"
                PRIVATE
                    -Werror
            )
        endif()
    else()
        message(WARNING
            "ProcLens warning configuration has not been defined for "
            "${CMAKE_CXX_COMPILER_ID}"
        )
    endif()
endfunction()

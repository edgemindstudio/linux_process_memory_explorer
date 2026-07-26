function(proclens_enable_sanitizers target_name)
    if(NOT TARGET "${target_name}")
        message(FATAL_ERROR
            "proclens_enable_sanitizers received unknown target: ${target_name}"
        )
    endif()

    if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
        message(WARNING
            "ProcLens sanitizers are not configured for "
            "${CMAKE_CXX_COMPILER_ID}"
        )
        return()
    endif()

    set(enabled_sanitizers)

    if(PROCLENS_ENABLE_ADDRESS_SANITIZER)
        list(APPEND enabled_sanitizers address)
    endif()

    if(PROCLENS_ENABLE_UNDEFINED_SANITIZER)
        list(APPEND enabled_sanitizers undefined)
    endif()

    if(PROCLENS_ENABLE_THREAD_SANITIZER)
        list(APPEND enabled_sanitizers thread)
    endif()

    if(NOT enabled_sanitizers)
        return()
    endif()

    if(PROCLENS_ENABLE_THREAD_SANITIZER
       AND PROCLENS_ENABLE_ADDRESS_SANITIZER)
        message(FATAL_ERROR
            "ThreadSanitizer cannot be combined with AddressSanitizer"
        )
    endif()

    list(JOIN enabled_sanitizers "," sanitizer_list)

    target_compile_options(
        "${target_name}"
        PRIVATE
            -fsanitize=${sanitizer_list}
            -fno-omit-frame-pointer
    )

    target_link_options(
        "${target_name}"
        PRIVATE
            -fsanitize=${sanitizer_list}
            -fno-omit-frame-pointer
    )
endfunction()

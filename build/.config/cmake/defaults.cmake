# Local defaults for every CMake project, loaded through CMAKE_TOOLCHAIN_FILE
# (set in .bashrc). A project or command line that sets these wins.
#
# Memory: Ninja runs as many compiles as there are cores. Achilles' compiles
# peak under 1 GB each, but the desktop (browser, Zoom, clangd) usually holds
# over 20 GB of the 30, so 14 at once can run out. These job pools cap parallel
# compiles at one per 4 GB of RAM (7 here), and links at 2. Set
# BUILD_COMPILE_JOBS=<n> when configuring to choose the cap. Pools only apply
# to Ninja; with Makefiles, pass -j yourself.
#
# Linking: lld instead of GNU ld, which is several times slower on big binaries.
include_guard(GLOBAL)

if(NOT DEFINED CMAKE_JOB_POOLS)
    file(STRINGS /proc/meminfo _defaults_mem REGEX "^MemTotal:")
    string(REGEX MATCH "[0-9]+" _defaults_kb "${_defaults_mem}")
    math(EXPR _defaults_compile "${_defaults_kb} / 4 / 1048576")
    if(DEFINED ENV{BUILD_COMPILE_JOBS})
        set(_defaults_compile $ENV{BUILD_COMPILE_JOBS})
    endif()
    cmake_host_system_information(RESULT _defaults_cores QUERY NUMBER_OF_LOGICAL_CORES)
    if(_defaults_compile GREATER _defaults_cores)
        set(_defaults_compile ${_defaults_cores})
    elseif(_defaults_compile LESS 1)
        set(_defaults_compile 1)
    endif()
    set(CMAKE_JOB_POOLS "compile=${_defaults_compile};link=2")
    set(CMAKE_JOB_POOL_COMPILE compile)
    set(CMAKE_JOB_POOL_LINK link)
endif()

if(NOT DEFINED CMAKE_LINKER_TYPE)
    find_program(_defaults_lld ld.lld)
    if(_defaults_lld)
        set(CMAKE_LINKER_TYPE LLD)
    endif()
endif()

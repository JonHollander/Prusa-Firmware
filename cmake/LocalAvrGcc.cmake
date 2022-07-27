get_filename_component(PROJECT_CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" DIRECTORY)
include("${PROJECT_CMAKE_DIR}/Utilities.cmake")
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR avr)
set(CMAKE_CROSSCOMPILING 1)
get_dependency_directory("avr-gcc" AVR_TOOLCHAIN_DIR)
message( "tc dir is ${AVR_TOOLCHAIN_DIR}")
#
# Utilities

if(MINGW
   OR CYGWIN
   OR WIN32
   )
  set(UTIL_SEARCH_CMD where)
  set(EXECUTABLE_SUFFIX ".exe")
elseif(UNIX OR APPLE)
  set(UTIL_SEARCH_CMD which)
  set(EXECUTABLE_SUFFIX "")
endif()

set(TOOLCHAIN_PREFIX avr-)

#
# Looking up the toolchain
#

if(AVR_TOOLCHAIN_DIR)
  # using toolchain set by AvrGcc.cmake (locked version)
  set(BINUTILS_PATH "${AVR_TOOLCHAIN_DIR}/bin")
else()
  # search for ANY avr-gcc toolchain
  execute_process(
    COMMAND ${UTIL_SEARCH_CMD} ${TOOLCHAIN_PREFIX}gcc
    OUTPUT_VARIABLE AVR_GCC_PATH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE FIND_RESULT
    )
  # found?
  if(NOT "${FIND_RESULT}" STREQUAL "0")
    message(FATAL_ERROR "avr-gcc not found")
  endif()
  get_filename_component(BINUTILS_PATH "${AVR_GCC_PATH}" DIRECTORY)
  get_filename_component(AVR_TOOLCHAIN_DIR ${BINUTILS_PATH} DIRECTORY)
endif()

#
# Setup CMake
#

# Without that flag CMake is not able to pass test compilation check
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_C_COMPILER
    "${BINUTILS_PATH}/${TOOLCHAIN_PREFIX}gcc${EXECUTABLE_SUFFIX}"
    CACHE FILEPATH "" FORCE
    )
set(CMAKE_ASM_COMPILER
    "${BINUTILS_PATH}/${TOOLCHAIN_PREFIX}gcc${EXECUTABLE_SUFFIX}"
    CACHE FILEPATH "" FORCE
    )
set(CMAKE_CXX_COMPILER
    "${BINUTILS_PATH}/${TOOLCHAIN_PREFIX}g++${EXECUTABLE_SUFFIX}"
    CACHE FILEPATH "" FORCE
    )
set(CMAKE_EXE_LINKER_FLAGS_INIT
    ""
    CACHE STRING "" FORCE
    )

set(CMAKE_ASM_COMPILE_OBJECT
    "<CMAKE_ASM_COMPILER> <DEFINES> <FLAGS> -o <OBJECT> -c <SOURCE>"
    CACHE STRING "" FORCE
    )

set(CMAKE_OBJCOPY
    "${BINUTILS_PATH}/${TOOLCHAIN_PREFIX}objcopy${EXECUTABLE_SUFFIX}"
    CACHE INTERNAL "objcopy tool"
    )
set(CMAKE_OBJDUMP
    "${BINUTILS_PATH}/${TOOLCHAIN_PREFIX}objdump${EXECUTABLE_SUFFIX}"
    CACHE INTERNAL "objdump tool"
    )
set(CMAKE_SIZE_UTIL
    "${BINUTILS_PATH}/${TOOLCHAIN_PREFIX}size${EXECUTABLE_SUFFIX}"
    CACHE INTERNAL "size tool"
    )

set(CMAKE_FIND_ROOT_PATH "${AVR_TOOLCHAIN_DIR}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

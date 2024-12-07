set(BUILD_INFO_PATH "${CMAKE_BINARY_DIR}/build_info.h")
set(TEMP_BUILD_INFO_PATH "${CMAKE_BINARY_DIR}/build_info.tmp.h")

file(WRITE "${TEMP_BUILD_INFO_PATH}" "// This file is generated by CMake. Do not edit it manually.\n\n")
file(APPEND "${TEMP_BUILD_INFO_PATH}" "#pragma once\n\n")

execute_process(
        COMMAND git rev-parse HEAD
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        OUTPUT_VARIABLE SOLSTICE_BUILD_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
)
file(APPEND "${TEMP_BUILD_INFO_PATH}" "#define SOLSTICE_BUILD_VERSION \"${SOLSTICE_BUILD_VERSION}\"\n")
message(STATUS "Build version: ${SOLSTICE_BUILD_VERSION}")

string(SUBSTRING "${SOLSTICE_BUILD_VERSION}" 0 7 SOLSTICE_BUILD_VERSION_SHORT)
file(APPEND "${TEMP_BUILD_INFO_PATH}" "#define SOLSTICE_BUILD_VERSION_SHORT \"${SOLSTICE_BUILD_VERSION_SHORT}\"\n")
message(STATUS "Build version (short): ${SOLSTICE_BUILD_VERSION_SHORT}")

execute_process(
        COMMAND git rev-parse --abbrev-ref HEAD
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        OUTPUT_VARIABLE SOLSTICE_BUILD_BRANCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
)
file(APPEND "${TEMP_BUILD_INFO_PATH}" "#define SOLSTICE_BUILD_BRANCH \"${SOLSTICE_BUILD_BRANCH}\"\n")
message(STATUS "Build branch: ${SOLSTICE_BUILD_BRANCH}")

execute_process(
        COMMAND git log -1 --pretty=%B
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        OUTPUT_VARIABLE SOLSTICE_BUILD_COMMIT_MESSAGE
        OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(REGEX REPLACE "\n.*" "" SOLSTICE_BUILD_COMMIT_MESSAGE "${SOLSTICE_BUILD_COMMIT_MESSAGE}")
string(REPLACE "\"" "\\\"" SOLSTICE_BUILD_COMMIT_MESSAGE "${SOLSTICE_BUILD_COMMIT_MESSAGE}")
file(APPEND "${TEMP_BUILD_INFO_PATH}" "#define SOLSTICE_BUILD_COMMIT_MESSAGE \"${SOLSTICE_BUILD_COMMIT_MESSAGE}\"\n")
message(STATUS "Build commit message: ${SOLSTICE_BUILD_COMMIT_MESSAGE}")

execute_process(
        COMMAND git diff --name-only HEAD
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        OUTPUT_VARIABLE SOLSTICE_FILES_CHANGED
        OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(LENGTH "${SOLSTICE_FILES_CHANGED}" SOLSTICE_FILES_CHANGED_LENGTH)
string(REGEX REPLACE "\n" ";" SOLSTICE_FILES_CHANGED_LIST "${SOLSTICE_FILES_CHANGED}")
list(LENGTH SOLSTICE_FILES_CHANGED_LIST SOLSTICE_FILES_CHANGED_COUNT)
file(APPEND "${TEMP_BUILD_INFO_PATH}" "#define SOLSTICE_FILES_CHANGED_COUNT ${SOLSTICE_FILES_CHANGED_COUNT}\n")
message(STATUS "Files changed: ${SOLSTICE_FILES_CHANGED_COUNT}")

execute_process(
        COMMAND whoami
        OUTPUT_VARIABLE SOLSTICE_PC_USERNAME
        OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(REPLACE "\\" "/" SOLSTICE_PC_USERNAME "${SOLSTICE_PC_USERNAME}")
message(STATUS "PC username: ${SOLSTICE_PC_USERNAME}")
file(APPEND "${TEMP_BUILD_INFO_PATH}" "#define SOLSTICE_PC_USERNAME \"${SOLSTICE_PC_USERNAME}\"\n")

execute_process(
        COMMAND powershell -Command "get-appxpackage Microsoft.MinecraftUWP | Select InstallLocation"
        OUTPUT_VARIABLE MC_INSTALL_LOC
        OUTPUT_STRIP_TRAILING_WHITESPACE
)

if ("${MC_INSTALL_LOC}" STREQUAL "")
    set(MC_INSTALL_LOC "Unknown")
    set(SOLSTICE_INTENDED_VERSION "Unknown")
    message(WARNING "Minecraft install location: Unknown")
    message(WARNING "Intended version: Unknown")
else()
    string(REPLACE "\\" "/" MC_INSTALL_LOC "${MC_INSTALL_LOC}")
    string(REGEX REPLACE ".*\n" "" MC_INSTALL_LOC "${MC_INSTALL_LOC}")
    set(MC_INSTALL_LOC "${MC_INSTALL_LOC}/Minecraft.Windows.exe")

    message(STATUS "Minecraft install location: ${MC_INSTALL_LOC}")

    execute_process(
            COMMAND powershell -Command "(Get-Command \"${MC_INSTALL_LOC}\").Version"
            OUTPUT_VARIABLE MC_VERSION
            OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    string(REGEX REPLACE ".*\n" "" MC_VERSION "${MC_VERSION}")
    string(REGEX REPLACE " +" "." MC_VERSION "${MC_VERSION}")
    set(SOLSTICE_INTENDED_VERSION "${MC_VERSION}")
    message(STATUS "Intended version: ${SOLSTICE_INTENDED_VERSION}")
endif()

file(APPEND "${TEMP_BUILD_INFO_PATH}" "#define SOLSTICE_INTENDED_VERSION \"${SOLSTICE_INTENDED_VERSION}\"\n")

execute_process(
        COMMAND ${CMAKE_COMMAND} -E compare_files "${TEMP_BUILD_INFO_PATH}" "${BUILD_INFO_PATH}"
        RESULT_VARIABLE FILES_DIFFER
)

if (FILES_DIFFER)
    message(STATUS "Updating build_info.h")
    file(RENAME "${TEMP_BUILD_INFO_PATH}" "${BUILD_INFO_PATH}")
else()
    message(STATUS "No changes to build_info.h")
    file(REMOVE "${TEMP_BUILD_INFO_PATH}")
endif()
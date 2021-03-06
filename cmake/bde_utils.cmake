## bde_utils.cmake
## ---------------
#
#  This CMake module exposes a set of generic macros and functions providing
#  convenience utility.
#
## OVERVIEW
## --------
# o bde_utils_add_meta_file: parse content of the metadata file.
# o bde_utils_track_file:    track file changes to trigger a reconfiguration.
#
## ========================================================================= ##

if(BDE_UTILS_INCLUDED)
    return()
endif()
set(BDE_UTILS_INCLUDED true)

# :: bde_utils_add_meta_file ::
# -----------------------------------------------------------------------------
# Read the content of 'file' and store each token from it in the specified
# 'out' list.
#
# File is processed with respect to the following expected syntax:
#   o '#' with following text till the end of line is ignored
#   o ' ' is considered a token separator for splitting out multiple items from
#     a single line
#
## PARAMETERS
## ----------
# This function takes one optional parameter: 'TRACK'.  The 'file's content
# changes are not tracked by the build system unless 'TRACK' is specified.
#
## EXAMPLE
## -------
# If the 'file' contains the following:
#    a
#    b c d
#    # Comment
#    e # Comment
# The result will be: a;b;c;d;e
function(bde_utils_add_meta_file file out)
    # Parameters parse
    #   One optional parameter: TRACK
    cmake_parse_arguments(args "TRACK" "" "" ${ARGN})
    bde_assert_no_unparsed_args(args)

    # Read all lines from 'file', ignoring the ones starting with '#'
    file(STRINGS "${file}" lines REGEX "^[^#].*")

    set(tmp)

    # For each line, split at ' '
    foreach(line IN LISTS lines)
        # Remove comment
        string(REGEX REPLACE " *#.*$" "" line ${line})

        # In CMake a list is a string with ';' as an item separator.
        string(REGEX REPLACE " " ";" line ${line})

        if(NOT "${line}" STREQUAL "")
            list(APPEND tmp ${line})
        endif()
    endforeach()

    # Set the result
    set(${out} ${tmp} PARENT_SCOPE)

    # Track file for changes if told so.
    if(args_TRACK)
        bde_utils_track_file(${file})
    endif()
endfunction()

# :: bde_utils_track_file ::
# -----------------------------------------------------------------------------
# This function adds the specified 'file' to a set of generator dependancies
# forcing the reconfiguration of the file content changes.  This function is
# used to track changes in the .mem and .dep files.

# We copy the file to a directory under the current build directory; and by
# CMake's 'configure_file' contract, if the content has changed, this will
# trigger a 'rebuild_cache'.
#
## NOTE
## ----
# The monitored file is copied under a '.track/' directory in the current
# binary directory. Because we would only copy the file and lose the full path,
# potentially leading to silent collisions, the copied files name correspond to
# the first 10 characters of the SHA1 of the absolute path of the input 'file'.
function( bde_utils_track_file file )
    bde_assert_no_extra_args()

    # Get the real path to the file
    get_filename_component(realPath ${file} REALPATH)

    # Compute the SHA-1
    string(SHA1 sha ${realPath})

    # Keep the first ten characters
    string(SUBSTRING ${sha} 0 10 shortSha)

    # configure_file
    configure_file(
        ${file}
        "${CMAKE_CURRENT_BINARY_DIR}/.track/${shortSha}"
        COPYONLY
    )
endfunction()

macro(bde_return)
    list(GET ARGV 0 retVar)
        # Can't use ${ARGV0} as it would evaluate to ${var} and not the first
        # argument passed to surrounding function
    set(${retVar} ${ARGN} PARENT_SCOPE)
    return()
endmacro()

function(bde_utils_list_template_substitute retResult placeholder template)
    set(result)
    foreach(target IN LISTS ARGN)
        string(REPLACE ${placeholder} ${target} elem ${template})
        list(APPEND result ${elem})
    endforeach()
    bde_return(${result})
endfunction()

function(bde_utils_filter_directories retDirectories)
    set(dirs)
    foreach(f IN LISTS ARGN)
        if(IS_DIRECTORY ${f})
            list(APPEND dirs ${f})
        endif()
    endforeach()
    bde_return(${dirs})
endfunction()

function(bde_utils_find_file_extension retFullName baseName extensions)
    bde_assert_no_extra_args()

    foreach(ext IN LISTS extensions)
        set(fullName ${baseName}${ext})
        if(EXISTS ${fullName})
            bde_return(${fullName})
        endif()
    endforeach()

    bde_return("")
endfunction()

function(bde_append_test_labels test)
    set_property(
        TEST ${test}
        APPEND PROPERTY
        LABELS ${ARGN}
    )
endfunction()

macro(bde_assert_no_extra_args)
    if (ARGN)
        # This 'conversion' is required to use the ARGN actually passed
        # to the surrounding function and not the macro itself
        set(args)
        foreach(var IN LISTS ARGN)
            list(APPEND args ${var})
        endforeach()

        message(
            FATAL_ERROR
            "Unexpected extra arguments passed to function: ${args}"
        )

    endif()
endmacro()

macro(bde_assert_no_unparsed_args prefix)
    if (${prefix}_UNPARSED_ARGUMENTS)
        message(
            FATAL_ERROR
            "Unknown arguments arguments passed to function:\
            ${${prefix}_UNPARSED_ARGUMENTS}."
        )
    endif()
endmacro()

function(bde_add_executable target)
    add_executable(${target} ${ARGN} "")
    set_target_properties(
        ${target} PROPERTIES SUFFIX ".tsk${CMAKE_EXECUTABLE_SUFFIX}"
    )
endfunction()
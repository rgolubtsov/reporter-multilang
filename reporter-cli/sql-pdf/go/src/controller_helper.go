/*
 * reporter-cli/sql-pdf/go/src/controller_helper.go
 * ============================================================================
 * Reporter Multilang. Version 0.1
 * ============================================================================
 * A tool to generate human-readable reports based on data from various sources
 * with the focus on its implementation using a series of programming languages
 * ============================================================================
 * Written by Radislav (Radicchio) Golubtsov, 2016-2017
 *
 * This is free and unencumbered software released into the public domain.
 *
 * Anyone is free to copy, modify, publish, use, compile, sell, or
 * distribute this software, either in source code form or as a compiled
 * binary, for any purpose, commercial or non-commercial, and by any
 * means.
 *
 * (See the LICENSE file at the top of the source tree.)
 */

package main

// Helper constants.
const _EXIT_FAILURE    int    =    1 //    Failing exit status.
const _EXIT_SUCCESS    int    =    0 // Successful exit status.
const _EMPTY_STRING    string =   ""
const _NEW_LINE        string = "\n"
const _S_FMT           string = "%s"
const _COLON_SPACE_SEP string = ": "
const _COLON           string =  ":"
const _SLASH           string =  "/"
const _AT              string =  "@"
const _QM              string =  "?"
const _SQ              string =  "'"
const _V_BAR           string =  "|"
const _SPACE           string =  " "
const _SEP_NOD         string =  "+"
const _SEP_COG         string =  "-"
const _CURRENT_DIR     string = "./"

// Common error messages.
const _ERROR_PREFIX        string = "Error"
const _ERROR_NO_DB_CONNECT string = "Could not connect to the database. "
const _ERROR_NO_DATA       string = "No data found."
const _ERROR_NO_REPORT_GEN string = "Could not generate the report."

/** The helper for the controller class and related ones. */
type ControllerHelper struct {
    /*
     * In Vala/Genie this helper class contains commonly used constants
     * and nothing more. But Go doesn't allow constants to be declared
     * inside a class. Hence, the presence of this class is completely
     * useless in the context of the given app, but let it exist anyway,
     * in a "reserved" state.
     */
}

// vim:set nu:et:ts=4:sw=4:

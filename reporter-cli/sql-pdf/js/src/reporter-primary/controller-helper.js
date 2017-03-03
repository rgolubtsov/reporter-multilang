/*
 * reporter-cli/sql-pdf/js/src/reporter-primary/controller-helper.js
 * =============================================================================
 * Reporter Multilang. Version 0.1
 * =============================================================================
 * A tool to generate human-readable reports based on data from various sources
 * with the focus on its implementation using a series of programming languages.
 * =============================================================================
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

"use strict";

/** The helper for the controller class and related ones. */
var ControllerHelper = function() {
    /* Constant: The name of the class. */
    var _CLASS_NAME = "ControllerHelper";

    /* Helper constants. */
    this._EXIT_FAILURE    =    1; //    Failing exit status.
    this._EXIT_SUCCESS    =    0; // Successful exit status.
    this._EMPTY_STRING    =   "";
    this._NEW_LINE        = "\n";
    this._COLON_SPACE_SEP = ": ";
    this._COLON           =  ":";
    this._SLASH           =  "/";
    this._AT              =  "@";
    this._QM              =  "?";
    this._SQ              =  "'";
    this._V_BAR           =  "|";
    this._SPACE           =  " ";
    this._SEP_NOD         =  "+";
    this._SEP_COG         =  "-";
    this._CURRENT_DIR     = "./";

    /* Common error messages. */
    this._ERROR_PREFIX        = "Error";
    this._ERROR_NO_DB_CONNECT = "Could not connect to the database. ";
    this._ERROR_NO_DATA       = "No data found.";
    this._ERROR_NO_REPORT_GEN = "Could not generate the report.";
};

module.exports = exports = ControllerHelper;

// vim:set nu:et:ts=4:sw=4:

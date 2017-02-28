/*
 * reporter-cli/sql-pdf/js/src/reporter-primary.js
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

var ControllerHelper = require("./reporter-primary/controller-helper.js");

/** The main class of the application. */
var ReporterPrimary = function() {
    /* The name of the class. */
    var _CLASS_NAME = "ReporterPrimary";

    /* Database switches. They indicate which database to connect to. */
    var _MY_CONNECT = "mysql";
    var _PG_CONNECT = "postgres";
    var _SL_CONNECT = "sqlite";

    /**
     * Starts up the app.
     *
     * @param args The array of command-line arguments.
     *
     * @return The exit code indicating the app overall execution status.
     */
    this.startup = function(args) {
        // Instantiating the controller helper class.
        var aux = new ControllerHelper();

        var ret = aux._EXIT_SUCCESS;

        var __name__ = _CLASS_NAME;

        var db_switch = args[0];

        var cnx = null;

        // Trying to connect to the database.
        try {
            // TODO: Implement connecting to the database.

                   if (db_switch === _MY_CONNECT) {
                cnx = _MY_CONNECT;
            } else if (db_switch === _PG_CONNECT) {
                cnx = _PG_CONNECT;
            } else if (db_switch === _SL_CONNECT) {
                cnx = _SL_CONNECT;
            } else                                {
                cnx = aux._EMPTY_STRING;
            }
        } catch (e) {
            ret = aux._EXIT_FAILURE;

            console.log(__name__ + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                                 + aux._COLON_SPACE_SEP + e);

            return ret;
        }

        console.log(__name__ + aux._COLON_SPACE_SEP + ret
                             + aux._SPACE           + aux._V_BAR
                             + aux._SPACE           + cnx);

        return ret;
    };
};

module.exports = exports = ReporterPrimary;

// vim:set nu:et:ts=4:sw=4:

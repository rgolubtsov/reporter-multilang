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

var mysql    = require("mysql");
var postgres = require("pg");
var sqlite   = require("sqlite3");

var ControllerHelper   = require("./reporter-primary/controller-helper.js");
var ReporterController = require("./reporter-primary/reporter-controller.js");

/** The main class of the application. */
var ReporterPrimary = function() {
    /* Constant: The name of the class. */
    var _CLASS_NAME = "ReporterPrimary";

    /* Database switches. They indicate which database to connect to. */
    var _MY_CONNECT = "mysql";
    var _PG_CONNECT = "postgres";
    var _SL_CONNECT = "sqlite";

    /**
     * Constant: The database server name.
     *     TODO: Move to cli args.
     */
    var HOSTNAME = "10.0.2.100";
//  var HOSTNAME = "localhost";

    /**
     * Constant: The username to connect to the database.
     *     TODO: Move to cli args.
     */
    var USERNAME = "reporter";

    /**
     * Constant: The password to connect to the database.
     *     TODO: Move to cli args.
     */
    var PASSWORD = "retroper12345678";

    /**
     * Constant: The database name.
     *     TODO: Move to cli args.
     */
    var DATABASE = "reporter_multilang";

    /**
     * Constant: The SQLite database location.
     *     TODO: Move to cli args.
     */
    var SQLITE_DB_DIR = "data";

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
        var __file__ = module.filename;

        var db_switch = args[0];

        var cnx = null;

        // Trying to connect to the database.
        try {
                   if (db_switch === _MY_CONNECT) {
                cnx = mysql.createConnection({
                        host : HOSTNAME,
                        user : USERNAME,
                    password : PASSWORD,
                    database : DATABASE,
                });
            } else if (db_switch === _PG_CONNECT) {
                cnx = new postgres.Client({
                        host : HOSTNAME,
                        user : USERNAME,
                    password : PASSWORD,
                    database : DATABASE,
                });
            } else if (db_switch === _SL_CONNECT) {
                var sqlite_db_path = _get_sqlite_db_path(__file__, aux);

                cnx = new sqlite.Database(
                    sqlite_db_path,
                    sqlite.OPEN_READONLY
                );
            }
        } catch (e) {
            ret = aux._EXIT_FAILURE;

            console.log(__name__ + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                                 + aux._COLON_SPACE_SEP + e);

            return ret;
        }

        if (cnx) {
            if (db_switch !== _SL_CONNECT) {
                cnx.connect();
            }

            // Instantiating the controller class.
            var ctrl = new ReporterController();

            // Generating the PDF report.
            ret = ctrl.pdf_report_generate(cnx);

            console.log(__name__ + aux._COLON_SPACE_SEP + cnx
                                 + aux._SPACE           + aux._V_BAR
                                 + aux._SPACE           + ret);

            // Disconnecting from the database.
            if (db_switch !== _SL_CONNECT) {
                cnx.end();
            } else {
                cnx.close();
            }
        } else {
            ret = aux._EXIT_FAILURE;

            console.log(__name__ + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                                 + aux._COLON_SPACE_SEP
                                 + aux._ERROR_NO_DB_CONNECT);

            return ret;
        }

        return ret;
    };

    /*
     * Helper method.
     * Returns the SQLite database path, relative to this module location.
     */
    var _get_sqlite_db_path = function(module_, aux) {
        var module_path    = module_.split(aux._SLASH);
        var module_name    = module_path.pop();
        var sqlite_db_path = module_path.join(aux._SLASH)
                           + aux._SLASH + SQLITE_DB_DIR
                           + aux._SLASH + DATABASE;

        return sqlite_db_path;
    };
};

module.exports = exports = ReporterPrimary;

// vim:set nu:et:ts=4:sw=4:

/*
 * reporter-cli/sql-pdf/js/src/reporter-primary/reporter-model.js
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

var ControllerHelper = require("./controller-helper.js");

/** The model class of the application. */
var ReporterModel = function() {
    /* Constant: The name of the class. */
    var _CLASS_NAME = "ReporterModel";

    /**
     * Retrieves a list of all data items stored in the database.
     *
     * @param cnx      The database connection object.
     * @param mysql    The indicator that shows whether the database connection
     *                 object is MySQL connection.
     * @param postgres The indicator that shows whether the database connection
     *                 object is PostgreSQL connection.
     * @param res_set  The callback function that will be returned
     *                 to the controller.
     *
     * @return The callback function containing table headers and rows.
     */
    this.get_all_data_items = function(cnx, mysql, postgres, res_set) {
        // Instantiating the controller helper class.
        var aux = new ControllerHelper();

        var __name__ = _CLASS_NAME;

        var sql_select = "select"
            + "      x0.name as arch,"
            + "      x1.name as repo,"
            + "   items.name,"
            + " attr_x2      as version,"
//          + "   items.description,"
            + " attr_x3      as last_updated,"
            + " attr_x4      as flag_date"
        + " from"
            + " data_items items,"
            + "   attr_x0s x0,"
            + "   attr_x1s x1"
        + " where"
            + " (attr_x0_id  = x0.id) and"
            + " (attr_x1_id  = x1.id)" // and"
//          + " (attr_x4 is not null)"
        + " order by"
            + " items.name,"
            + "       arch";

        if (mysql) {
            // Executing the SQL statement.
            cnx.query(sql_select, function(e, row_set, hdr_set) {
                if (e) { throw e; }

                return res_set(row_set, hdr_set);
            });
        } else if (postgres) {
            // Executing the SQL statement.
            var query = cnx.query(sql_select);

            query.on("error", function(e) { if (e) { throw e; }});

            var hdr_set = [];

            query.on("row", function(row_ary, row_set) {
                row_set.addRow(row_ary);
            });

            query.on("end", function(row_set) {
                cnx.end(function(e) { if (e) { throw e; }});

                return res_set(row_set.rows, hdr_set);
            });
        } else { // <== Suppose the database is SQLite.
            // Preparing the SQL statement.
            var stmt = cnx.prepare(sql_select, function(e) {
                if (e) { throw e; }
            });

            var row_set = [];
            var hdr_set = [];

            // Executing the SQL statement.
            stmt.each(function(e, row_ary) {
                if (e) { throw e; }

                row_set.push(row_ary);
            }, function(e, num_rows) {
                if (e) { throw e; }

                return res_set(row_set, hdr_set);
            });

            // Finalizing the SQL statement.
            stmt.finalize(function(e) { if (e) { throw e; }});
        }
    };
};

module.exports = exports = ReporterModel;

// vim:set nu:et:ts=4:sw=4:

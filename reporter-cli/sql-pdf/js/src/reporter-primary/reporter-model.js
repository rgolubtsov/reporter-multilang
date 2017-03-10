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

var CtrlHlpr = require("./controller-helper.js");

/** The model class of the application. */
var ReporterModel = function() {
    /* Constant: The name of the class. */
    var _CLASS_NAME = "ReporterModel";

    /* The Coordinated Universal Time (UTC) date conversion trick suffix. */
    var _UTC = "UTC";

    /* Various string literals. */
    var _ERROR_        = "error";
    var _ROW_          = "row";
    var _END_          = "end";
    // ------------------------------------------------------------------------
    var _ARCH_         = "arch";
    var _REPO_         = "repo";
    var _NAME_         = "name";
    var _VERSION_      = "version";
    var _LAST_UPDATED_ = "last_updated";
    var _FLAG_DATE_    = "flag_date";

    /**
     * Retrieves a list of all data items stored in the database.
     *
     * @param cnx      The database connection object.
     * @param mysql    The indicator that shows whether the database connection
     *                 object is MySQL connection.
     * @param postgres The indicator that shows whether the database connection
     *                 object is PostgreSQL connection.
     * @param res_set  The callback function that will be "returned"
     *                 to the controller.
     *
     * @return The callback function containing table headers and rows.
     */
    this.get_all_data_items = function(cnx, mysql, postgres, res_set) {
        // Instantiating the controller helper class.
        var aux = new CtrlHlpr.ControllerHelper();

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
            cnx.query(sql_select, function(e, row_lot, hdr_lot) {
                if (e) { throw e; }

                var num_hdrs = hdr_lot.length;
                var num_rows = row_lot.length;

                var hdr_set = [], row_set = [];

                // Processing the result set metadata -- table headers.
                for (var i = 0; i < num_hdrs; i++) {
                    hdr_set.push(hdr_lot[i].name);
                }

                // Processing the result set -- table rows.
                for (var i = 0; i < num_rows; i++) {
                    row_set.push([]); //<== Making a quasi-2-dimensional array.

                    for (var j = 0; j < num_hdrs; j++) {
                        var row_cur = row_lot[i][hdr_set[j]];

                        if ((j === 4) || (j === 5)) {
                            if (row_cur) {
                                row_cur = new Date(row_cur + _UTC)
                                                  .toISOString().slice(0, 10);
      // The same effect when using this one: ==> .toJSON().slice(0, 10);
                            } else {
                                row_cur = aux._EMPTY_STRING;
                            }
                        }

                        row_set[i].push(row_cur);
                    }
                }

                return res_set(hdr_set, row_set);
            });
        } else if (postgres) {
            // Executing the SQL statement.
            var query = cnx.query(sql_select);

            query.on(_ERROR_, function(e) { if (e) { throw e; }});

            query.on(_ROW_, function(row_ary, row_lot) {
                row_lot.addRow(row_ary);
            });

            query.on(_END_, function(row_lot) {
                cnx.end(function(e) { if (e) { throw e; }});

                var num_hdrs = row_lot.fields.length;
                var num_rows = row_lot.rows.length;

                var hdr_set = [], row_set = [];

                // Processing the result set metadata -- table headers.
                for (var i = 0; i < num_hdrs; i++) {
                    hdr_set.push(row_lot.fields[i].name);
                }

                // Processing the result set -- table rows.
                for (var i = 0; i < num_rows; i++) {
                    row_set.push([]); //<== Making a quasi-2-dimensional array.

                    for (var j = 0; j < num_hdrs; j++) {
                        var row_cur = row_lot.rows[i][hdr_set[j]];

                        if ((j === 4) || (j === 5)) {
                            if (row_cur) {
                                row_cur = new Date(row_cur + _UTC)
                                                  .toJSON().slice(0, 10);
      // The same effect when using this one: ==> .toISOString().slice(0, 10);
                            } else {
                                row_cur = aux._EMPTY_STRING;
                            }
                        }

                        row_set[i].push(row_cur);
                    }
                }

                return res_set(hdr_set, row_set);
            });
        } else { // <== Suppose the database is SQLite.
            // Preparing the SQL statement.
            var stmt = cnx.prepare(sql_select, function(e) {
                if (e) { throw e; }
            });

            var row_lot = [];

            // Executing the SQL statement.
            stmt.each(function(e, row_ary) {
                if (e) { throw e; }

                row_lot.push(row_ary);
            }, function(e, num_rows) {
                if (e) { throw e; }

                var hdr_set = [], row_set = [];

                // Constructing :-) the result set metadata -- table headers.
                hdr_set = [
                    _ARCH_,         // In the SQLite module there is no such
                    _REPO_,         // possibility to retrieve table headers
                    _NAME_,         // (column names) as there is implemented
                    _VERSION_,      // in MySQL and PostgreSQL modules (see
                    _LAST_UPDATED_, // above). So the only way is to populate
                    _FLAG_DATE_,    // and return this array of headers as is.
                ];

                var num_hdrs = hdr_set.length;

                // Processing the result set -- table rows.
                for (var i = 0; i < num_rows; i++) {
                    row_set.push([]); //<== Making a quasi-2-dimensional array.

                    for (var j = 0; j < num_hdrs; j++) {
                        var row_cur = row_lot[i][hdr_set[j]];

                        if ((j === 4) || (j === 5)) {
                            if (!row_cur) {
                                row_cur = aux._EMPTY_STRING;
                            }
                        }

                        row_set[i].push(row_cur);
                    }
                }

                return res_set(hdr_set, row_set);
            });

            // Finalizing the SQL statement.
            stmt.finalize(function(e) { if (e) { throw e; }});
        }
    };

    /**
     * Retrieves a list of data items for a given date period.
     *
     * @param from     The start date to retrieve data set.
     * @param to       The end   date to retrieve data set.
     * @param cnx      The database connection object.
     * @param mysql    The indicator that shows whether the database connection
     *                 object is MySQL connection.
     * @param postgres The indicator that shows whether the database connection
     *                 object is PostgreSQL connection.
     * @param res_set  The callback function that will be "returned"
     *                 to the controller.
     *
     * @return The callback function containing table headers and rows.
     */
    this.get_data_items_by_date = function(from,
                                           to,
                                           cnx,
                                           mysql,
                                           postgres,
                                           res_set) {

        // Instantiating the controller helper class.
        var aux = new CtrlHlpr.ControllerHelper();

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
            + " (attr_x0_id = x0.id) and"
            + " (attr_x1_id = x1.id) and";
// ----------------------------------------------------------------------------
// Note: PostgreSQL module (github.com/brianc/node-postgres) can handle only
//       dollar-sign-prefixed positional placeholders ($n), whilst MySQL module
//       (github.com/mysqljs/mysql) and SQLite (github.com/mapbox/node-sqlite3)
//       module both can handle only question-mark-placeholders (?).
//       So that the use of dollar-sign-prefixed placeholders
//       is mandatory only for PostgreSQL operations.
// ----------------------------------------------------------------------------
        if (postgres) {     sql_select
//          +=" (attr_x3    >=   $1) and"
//          + " (attr_x3    <=   $2)";
// ----------------------------------------------------------------------------
            +=" (attr_x3 between $1 and $2)";
// ----------------------------------------------------------------------------
        } else {            sql_select
//          +=" (attr_x3    >=    ?) and"
//          + " (attr_x3    <=    ?)";
// ----------------------------------------------------------------------------
            +=" (attr_x3 between  ? and  ?)";
// ----------------------------------------------------------------------------
        }                   sql_select
        +=" order by"
            + " items.name,"
            + "       arch";

        if (mysql) {
            // Executing the SQL statement.
            cnx.query(sql_select, [from, to], function(e, row_lot, hdr_lot) {
                if (e) { throw e; }

                var num_hdrs = hdr_lot.length;
                var num_rows = row_lot.length;

                var hdr_set = [], row_set = [];

                // Processing the result set metadata -- table headers.
                for (var i = 0; i < num_hdrs; i++) {
                    hdr_set.push(hdr_lot[i].name);
                }

                // Processing the result set -- table rows.
                for (var i = 0; i < num_rows; i++) {
                    row_set.push([]); //<== Making a quasi-2-dimensional array.

                    for (var j = 0; j < num_hdrs; j++) {
                        var row_cur = row_lot[i][hdr_set[j]];

                        if ((j === 4) || (j === 5)) {
                            if (row_cur) {
                                row_cur = new Date(row_cur + _UTC)
                                                  .toISOString().slice(0, 10);
                            } else {
                                row_cur = aux._EMPTY_STRING;
                            }
                        }

                        row_set[i].push(row_cur);
                    }
                }

                return res_set(hdr_set, row_set);
            });
        } else if (postgres) {
            // Executing the SQL statement.
            var query = cnx.query(sql_select, [from, to]);

            query.on(_ERROR_, function(e) { if (e) { throw e; }});

            query.on(_ROW_, function(row_ary, row_lot) {
                row_lot.addRow(row_ary);
            });

            query.on(_END_, function(row_lot) {
                cnx.end(function(e) { if (e) { throw e; }});

                var num_hdrs = row_lot.fields.length;
                var num_rows = row_lot.rows.length;

                var hdr_set = [], row_set = [];

                // Processing the result set metadata -- table headers.
                for (var i = 0; i < num_hdrs; i++) {
                    hdr_set.push(row_lot.fields[i].name);
                }

                // Processing the result set -- table rows.
                for (var i = 0; i < num_rows; i++) {
                    row_set.push([]); //<== Making a quasi-2-dimensional array.

                    for (var j = 0; j < num_hdrs; j++) {
                        var row_cur = row_lot.rows[i][hdr_set[j]];

                        if ((j === 4) || (j === 5)) {
                            if (row_cur) {
                                row_cur = new Date(row_cur + _UTC)
                                                  .toJSON().slice(0, 10);
                            } else {
                                row_cur = aux._EMPTY_STRING;
                            }
                        }

                        row_set[i].push(row_cur);
                    }
                }

                return res_set(hdr_set, row_set);
            });
        } else { // <== Suppose the database is SQLite.
            // Preparing the SQL statement.
            var stmt = cnx.prepare(sql_select, [from, to], function(e) {
                if (e) { throw e; }
            });

            var row_lot = [];

            // Executing the SQL statement.
            stmt.each(function(e, row_ary) {
                if (e) { throw e; }

                row_lot.push(row_ary);
            }, function(e, num_rows) {
                if (e) { throw e; }

                var hdr_set = [], row_set = [];

                // Constructing :-) the result set metadata -- table headers.
                hdr_set = [
                       _ARCH_,         _REPO_,      _NAME_,
                    _VERSION_, _LAST_UPDATED_, _FLAG_DATE_,
                ];

                var num_hdrs = hdr_set.length;

                // Processing the result set -- table rows.
                for (var i = 0; i < num_rows; i++) {
                    row_set.push([]); //<== Making a quasi-2-dimensional array.

                    for (var j = 0; j < num_hdrs; j++) {
                        var row_cur = row_lot[i][hdr_set[j]];

                        if ((j === 4) || (j === 5)) {
                            if (!row_cur) {
                                row_cur = aux._EMPTY_STRING;
                            }
                        }

                        row_set[i].push(row_cur);
                    }
                }

                return res_set(hdr_set, row_set);
            });

            // Finalizing the SQL statement.
            stmt.finalize(function(e) { if (e) { throw e; }});
        }
    };
};

module.exports = exports = ReporterModel;

// vim:set nu:et:ts=4:sw=4:

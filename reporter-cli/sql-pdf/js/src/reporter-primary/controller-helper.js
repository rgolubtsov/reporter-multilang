/*
 * reporter-cli/sql-pdf/js/src/reporter-primary/controller-helper.js
 * =============================================================================
 * Reporter Multilang. Version 0.5.9
 * =============================================================================
 * A tool to generate human-readable reports based on data from various sources
 * with the focus on its implementation using a series of programming languages.
 * =============================================================================
 * Written by Radislav (Radicchio) Golubtsov, 2016-2025
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

/**
 * This class is a simplified JavaScript implementation of well-known
 * and very attractive Text::TabularDisplay Perl module by Darren Chamberlain:
 * http://search.cpan.org/~darren/Text-TabularDisplay-1.38/TabularDisplay.pm .
 *
 * The output is identical to that generated by the MySQL/MariaDB CLI client
 * when doing something like 'select ... from ... where ...;' query
 * on a database table.
 *
 * See comments in respective methods for their proper usage.
 *
 * @param _hdr_set The table headers (headings). (Simple array of strings.)
 */
var TabularDisplay = function(_hdr_set) {
    /* Constant: The name of the class. */
    var _CLASS_NAME = "TabularDisplay";

    /** The table headers (headings). */
    var hdr_set;

    /** The table rows (table body data). */
    var row_set;

    /**
     * The finally consolidated tabular data,
     * which has to be printed to the client.
     */
    var tableau = [];

    if (_hdr_set) {
        hdr_set = _hdr_set;
    } else {
        hdr_set = [];
    }

    /**
     * Populates class data members with the given table data.
     *
     * @param _row_set The table rows (table body data).
     *                 (2D-array of strings.)
     */
    this.populate = function(_row_set) {
        var aux = new ControllerHelper();

        if (_row_set) {
            var num_hdrs = _row_set[0].length;
            var num_rows = _row_set.length;

            row_set = _row_set;
// ----------------------------------------------------------------------------
            var hdr_set_len = []; //           [num_hdrs]
            var row_set_len = []; // [num_rows][num_hdrs]
            var col_max_len = []; // [num_rows]

            // Making a quasi-two-dimensional array.
            for (var i = 0; i < num_rows; i++) {
                row_set_len.push([]);
            }
// ----------------------------------------------------------------------------
            // Searching for the max data length in each column
            // to form its width.
            for (var j = 0; j < num_hdrs; j++) {
                hdr_set_len.push(hdr_set[j].length);

                for (var i = 0; i < num_rows; i++) {
                    row_set_len[i].push(row_set[i][j].length);
                }

                // Assuming this is the max.
                col_max_len.push(row_set_len[0][j]);

                // Searching for the max element in a column.
                for (var i = 0; i < num_rows; i++) {
                    if (row_set_len[i][j] > col_max_len[j]) {
                        col_max_len[j] = row_set_len[i][j];
                    }
                }
            }
// ----------------------------------------------------------------------------
            _separator_draw(num_hdrs, hdr_set_len, col_max_len, aux);
//          console.log (             );
            tableau.push(aux._NEW_LINE);
// ----------------------------------------------------------------------------
            // Printing table headers.
            for (var i = 0; i < num_hdrs; i++) {
//              process.stdout.write(aux._V_BAR + aux._SPACE + hdr_set[i]);
                tableau.push        (aux._V_BAR + aux._SPACE + hdr_set[i]);

                var spacers = 0;

                if (hdr_set_len[i] < col_max_len[i]) {
                    spacers = col_max_len[i] - hdr_set_len[i];
                }

                spacers++; // <== Additional spacer (padding).

                for (var m = 0; m < spacers; m++) {
//                  process.stdout.write(aux._SPACE);
                    tableau.push        (aux._SPACE);
                }
            }

//          console.log (aux._V_BAR);
            tableau.push(aux._V_BAR + aux._NEW_LINE);
// ----------------------------------------------------------------------------
            _separator_draw(num_hdrs, hdr_set_len, col_max_len, aux);
//          console.log (             );
            tableau.push(aux._NEW_LINE);
// ----------------------------------------------------------------------------
            // Printing table rows.
            for (var i = 0; i < num_rows; i++) {
                for (var j = 0; j < num_hdrs; j++) {
//                  process.stdout.write(aux._V_BAR+aux._SPACE+row_set[i][j]);
                    tableau.push        (aux._V_BAR+aux._SPACE+row_set[i][j]);

                    if (col_max_len[j] < hdr_set_len[j]) {
                        col_max_len[j] = hdr_set_len[j];
                    }

                    var spacers = 0;

                    if (row_set_len[i][j] < col_max_len[j]) {
                        spacers = col_max_len[j] - row_set_len[i][j];
                    }

                    spacers++; // <== Additional spacer (padding).

                    for (var m = 0; m < spacers; m++) {
//                      process.stdout.write(aux._SPACE);
                        tableau.push        (aux._SPACE);
                    }
                }

//              console.log (aux._V_BAR);
                tableau.push(aux._V_BAR + aux._NEW_LINE);
            }
// ----------------------------------------------------------------------------
            _separator_draw(num_hdrs, hdr_set_len, col_max_len, aux);
// ----------------------------------------------------------------------------
        } else {
            row_set = [];
        }
    };

    /**
     * Renders class data into string representation,
     * which is ready to be printed to the client.
     *
     * @return The string representation of collected tabular data.
     */
    this.render = function() {
        var aux = new ControllerHelper();

        var tableau_str = aux._EMPTY_STRING;

        if (tableau) {
            for (var i = 0; i < tableau.length; i++) {
                tableau_str += tableau[i];
            }
        }

        return tableau_str;
    };

    /* Helper method. Draws a horizontal separator for a table. */
    var _separator_draw = function(num_hdrs, hdr_set_len, col_max_len, aux) {
        for (var i = 0; i < num_hdrs; i++) {
//          process.stdout.write(aux._SEP_NOD);
            tableau.push        (aux._SEP_NOD);

            var sep_len = hdr_set_len[i];

            if (sep_len < col_max_len[i]) {
                sep_len = col_max_len[i];
            }

            sep_len += 2; // <== Two additional separator cogs (padding).

            for (var m = 0; m < sep_len; m++) {
//              process.stdout.write(aux._SEP_COG);
                tableau.push        (aux._SEP_COG);
            }
        }

//      process.stdout.write(aux._SEP_NOD);
        tableau.push        (aux._SEP_NOD);
    };
};

module.exports = exports = {
    ControllerHelper : ControllerHelper,
    TabularDisplay   : TabularDisplay,
};

// vim:set nu et ts=4 sw=4:

/*
 * reporter-cli/sql-pdf/js/src/reporter-primary/reporter-controller.js
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
var ReporterModel    = require("./reporter-model.js");

/** The controller class of the application. */
var ReporterController = function() {
    /* Constant: The name of the class. */
    var _CLASS_NAME = "ReporterController";

    /**
     * Constant: The start date to retrieve data set.
     *     TODO: Move to cli args.
     */
    var FROM = "2016-06-01";

    /**
     * Constant: The end   date to retrieve data set.
     *     TODO: Move to cli args.
     */
    var TO   = "2016-12-01";

    /**
     * Generates the PDF report.
     *
     * @param cnx The database connection object.
     *
     * @return The exit code indicating the status
     *         of generating the PDF report.
     */
    this.pdf_report_generate = function(cnx) {
        // Instantiating the controller helper class.
        var aux = new ControllerHelper();

        var ret = aux._EXIT_SUCCESS;

        var __name__ = _CLASS_NAME;

        // Instantiating the model class.
        var model = new ReporterModel();

        // Retrieving a list of all data items stored in the database.
        var res_set = model.get_all_data_items(cnx);

        // Retrieving a list of data items for a given date period.
//      var res_set = model.get_data_items_by_date(FROM, TO, cnx);

        var hdr_set = res_set[0];
        var row_set = res_set[1];

        console.log(__name__ + aux._COLON_SPACE_SEP + cnx
                             + aux._SPACE           + aux._V_BAR
                             + aux._SPACE           + hdr_set
                             + aux._SPACE           + aux._V_BAR
                             + aux._SPACE           + row_set);

        return ret;
    };
};

module.exports = exports = ReporterController;

// vim:set nu:et:ts=4:sw=4:

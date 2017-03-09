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

var CtrlHlpr      = require("./controller-helper.js");
var ReporterModel = require("./reporter-model.js");

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
     * Constant: The PDF report output location.
     *     TODO: Move to cli args.
     */
    var PDF_REPORT_DIR = "lib/data";

    /**
     * Constant: The PDF report filename.
     *     TODO: Move to cli args.
     */
    var PDF_REPORT_FILENAME = "packages.pdf";

    /**
     * Constant: The number of pages generated in a PDF report.
     *     TODO: Move to cli args.
     */
    var MAX_PAGES = 20;

    /** Constant: The maximum number of data rows displayed in a page. */
    var MAX_ROWS_IN_A_PAGE = 40;

    /** Constant: The PDF basic measurement unit -- PostScript point. */
    var PT =   1;

    /** Constant: The one inch       (in PDF measurement terms). */
    var IN = ( 1   / 72);

    /** Constant: The one millimeter (in PDF measurement terms). */
    var MM = (25.4 / 72);

    /**
     * Generates the PDF report.
     *
     * @param cnx      The database connection object.
     * @param mysql    The indicator that shows whether the database connection
     *                 object is MySQL connection.
     * @param postgres The indicator that shows whether the database connection
     *                 object is PostgreSQL connection.
     *
     * @return The exit code indicating the status
     *         of generating the PDF report.
     */
    this.pdf_report_generate = function(cnx, mysql, postgres) {
        // Instantiating the controller helper class.
        var aux = new CtrlHlpr.ControllerHelper();

        var ret = aux._EXIT_SUCCESS;

        var __name__ = _CLASS_NAME;

        // Instantiating the model class.
        var model = new ReporterModel();

        // Retrieving a list of all data items stored in the database.
        model.get_all_data_items(cnx, mysql, postgres,
        function(hdr_set, row_set) {
            var num_hdrs = hdr_set.length;
            var num_rows = row_set.length;

            // In case of getting an empty result set, informing the user.
            if (num_hdrs === 0) {
                ret = aux._EXIT_FAILURE;

                console.log(__name__ + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                                     + aux._COLON_SPACE_SEP
                                     + aux._ERROR_NO_DATA);

                return ret;
            }

            // ----------------------------------------------------------------
            // --- Debug output - Begin ---------------------------------------
            // ----------------------------------------------------------------
            var dbg_output = new CtrlHlpr.TabularDisplay(hdr_set);

            dbg_output.populate(row_set);

            console.log(dbg_output.render());
            // ----------------------------------------------------------------
            // --- Debug output - End -----------------------------------------
            // ----------------------------------------------------------------
        });

        // Retrieving a list of data items for a given date period.
//      model.get_data_items_by_date(FROM, TO, cnx, mysql, postgres,
//      function(hdr_set, row_set) {});

        // TODO: Implement generating the PDF report.

        return ret;
    };
};

module.exports = exports = ReporterController;

// vim:set nu:et:ts=4:sw=4:

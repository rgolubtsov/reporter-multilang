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

var sleep  = require("sleep");
var Canvas = require("canvas");
var fs     = require("fs");

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
    var PDF_REPORT_DIR = "data";

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

    /* Various string literals. */
    var _PDF = "pdf";
    // ------------------------------------------------------------------------
    var _REPORT_TITLE         = "Arch Linux Packages";
    var _REPORT_AUTHOR        = "Arch Linux Package Maintainers";
    var _REPORT_SUBJECT       = "Sample list of Arch Linux packages.";
    var _REPORT_KEYWORDS      = "Linux ArchLinux Packages Arch Repo "
                              + "core extra community multilib";
    var _REPORT_CREATOR       = "Reporter Multilang 0.1 - "
                              + "https://github.com/rgolubtsov/"
                              + "reporter-multilang";
    // ------------------------------------------------------------------------
    var _ROWS_IN_SET_FOOTER   = " rows in set";
    var _ROWS_SHOWN_FOOTER    = "  (" + MAX_ROWS_IN_A_PAGE + " rows shown)";
    var _PDF_REPORT_SAVED_MSG = "PDF report saved";

    /**
     * Generates the PDF report.
     *
     * @param cnx      The database connection object.
     * @param mysql    The indicator that shows whether the database connection
     *                 object is MySQL connection.
     * @param postgres The indicator that shows whether the database connection
     *                 object is PostgreSQL connection.
     *
     * @return The exit code indicating the status of generating
     *         the PDF report. (Due to asynchronicity of model calls
     *         it'll be always successful and explicitly presented
     *         in this method for conforming to other blocking implementations
     *         (Python/Vala/Go, etc.) only. Don't rely on it seriously.)
     */
    this.pdf_report_generate = function(cnx, mysql, postgres) {
        // Instantiating the controller helper class.
        var aux = new CtrlHlpr.ControllerHelper();

        var ret = aux._EXIT_SUCCESS;

        var __name__ = _CLASS_NAME;
        var __file__ = module.filename;

        // Instantiating the model class.
        var model = new ReporterModel();

        // Retrieving a list of all data items stored in the database.
//      model.get_all_data_items(cnx, mysql, postgres,
//      function(hdr_set, row_set) {
//          _do_all_the_rest(hdr_set, row_set, aux, __name__, __file__);
//      });

        // Retrieving a list of data items for a given date period.
        model.get_data_items_by_date(FROM, TO, cnx, mysql, postgres,
        function(hdr_set, row_set) {
            _do_all_the_rest(hdr_set, row_set, aux, __name__, __file__);
        });

        return ret;
    };

    /* Helper/common method for using in both async model calls. */
    var _do_all_the_rest = function(hdr_set, row_set, aux, __name__, __file__){
        var ret = aux._EXIT_SUCCESS;

        var num_hdrs = hdr_set.length;
        var num_rows = row_set.length;

        // In case of getting an empty result set, informing the user.
        if (num_hdrs === 0) {
            ret = aux._EXIT_FAILURE;

            console.log(__name__ + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                                 + aux._COLON_SPACE_SEP + aux._ERROR_NO_DATA);

            return ret;
        }

        // --------------------------------------------------------------------
        // --- Debug output - Begin -------------------------------------------
        // --------------------------------------------------------------------
        var dbg_output = new CtrlHlpr.TabularDisplay(hdr_set);

        dbg_output.populate(row_set);

        console.log(dbg_output.render());

        console.log(num_rows + _ROWS_IN_SET_FOOTER + aux._NEW_LINE);
        // --------------------------------------------------------------------
        // --- Debug output - End ---------------------------------------------
        // --------------------------------------------------------------------

        sleep.sleep(1); // <== Waiting one second...just for fun...:-)...-- OK.

        // --------------------------------------------------------------------
        // --- Generating the PDF report - Begin ------------------------------
        // --------------------------------------------------------------------
        var pdf_report_path = _get_pdf_report_path(__file__, aux);

        var _report = new Canvas((210 / MM), (297 / MM), _PDF);

        var report = _report.getContext();

        // TODO: Implement generating the PDF report (here).

        var pdf_stream = _report.createPDFStream();
        var pdf_report = fs.createWriteStream(pdf_report_path);

        // --- Report metadata ------------------------------------------------
        /*
         * Note: The possibility to inject PDF metadata entries has appeared
         *       in Cairo 1.16, but even in Arch Linux the "cairo" package
         *       currently is just of version 1.14.8. And, of course,
         *       its Node.js bindings are in the same state. After upgrading
         *       to Cairo 1.16+ appropriate calls should look something
         *       like the given below (commented out for now).
         *       (Also note that the "canvas" npm package used
         *       must explicitly implement it.)
         *
         * See for reference:
         *   - Cairo sources:
         *       https://cgit.freedesktop.org/cairo/tree/src/cairo-pdf.h
         *       https://cgit.freedesktop.org/cairo/tree/src/
         *                                           cairo-pdf-surface.c
         *
         *   - canvas at npm:
         *       https://npmjs.com/package/canvas
         */
//      _report.set_metadata(Canvas.TITLE,    _REPORT_TITLE   );
//      _report.set_metadata(Canvas.AUTHOR,   _REPORT_AUTHOR  );
//      _report.set_metadata(Canvas.SUBJECT,  _REPORT_SUBJECT );
//      _report.set_metadata(Canvas.KEYWORDS, _REPORT_KEYWORDS);
//      _report.set_metadata(Canvas.CREATOR,  _REPORT_CREATOR );

        /*
         * Attaching the Writable stream to the Readable stream
         * and pushing all of its data to the attached one, i.e.:
         *              (W) pdf_report   <==   (R) pdf_stream
         */
        pdf_stream.pipe(pdf_report);

        console.log(_PDF_REPORT_SAVED_MSG + aux._COLON_SPACE_SEP
                                          + pdf_report_path);
        // --------------------------------------------------------------------
        // --- Generating the PDF report - End --------------------------------
        // --------------------------------------------------------------------

        return ret;
    };

    /*
     * Helper method.
     * Returns the generated PDF report output path,
     * relative to this module location.
     * TODO: Remove this method when the report output location
     *       will be passed through cli args.
     */
    var _get_pdf_report_path = function(module_, aux) {
        var module_path     = module_.split(aux._SLASH);
        var module_name     = module_path.pop();
        var package_name    = module_path.pop();
        var pdf_report_path = module_path.join(aux._SLASH)
                            + aux._SLASH + PDF_REPORT_DIR
                            + aux._SLASH + PDF_REPORT_FILENAME;

        return pdf_report_path;
    };
};

module.exports = exports = ReporterController;

// vim:set nu:et:ts=4:sw=4:

/*
 * reporter-cli/sql-pdf/js/src/reporter-primary/reporter-controller.js
 * =============================================================================
 * Reporter Multilang. Version 0.1
 * =============================================================================
 * A tool to generate human-readable reports based on data from various sources
 * with the focus on its implementation using a series of programming languages.
 * =============================================================================
 * Written by Radislav (Radicchio) Golubtsov, 2016-2020
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

    /** Constant: The vertical coordinate flipping normalizer. */
    var ZZ = 297;

    /* Various string literals. */
    var _PDF                     = "pdf";
    var _2D                      = "2d";
    // ------------------------------------------------------------------------
    var _REPORT_TITLE            = "Arch Linux Packages";
    var _REPORT_AUTHOR           = "Arch Linux Package Maintainers";
    var _REPORT_SUBJECT          = "Sample list of Arch Linux packages.";
    var _REPORT_KEYWORDS         = "Linux ArchLinux Packages Arch Repo "
                                 + "core extra community multilib";
    var _REPORT_CREATOR          = "Reporter Multilang 0.1 - "
                                 + "https://github.com/rgolubtsov/"
                                 + "reporter-multilang";
    // ------------------------------------------------------------------------
    var _RAINY_NIGHT_COLOR       = "#224488";
    var _WHITE_COLOR             = "#ffffff";
    var _BLACK_COLOR             = "#000000";
    var _RAINY_DAY_COLOR         = "#dddddd";
    var _VERY_LIGHT_COBALT_COLOR = "#aaaaaa";
    var _YET_NOT_WHITE_COLOR     = "#eeeeee";
    // ------------------------------------------------------------------------
    var _PANGO_WEIGHT_NORMAL     = "400";
    var _PANGO_WEIGHT_SEMIBOLD   = "600";
    // ------------------------------------------------------------------------
    // --- /usr/share/fonts/100dpi/helv*.pcf.gz -------
    var _SANS_FONT               = "Helvetica";
    // --- /usr/share/fonts/TTF/DejaVuSan*.ttf --------
//  var _SANS_FONT               = "DejaVu Sans";
    // --- /usr/share/fonts/TTF/LiberationSan*.ttf ----
//  var _SANS_FONT               = "Liberation Sans";
    // --- /usr/share/fonts/100dpi/tim*.pcf.gz --------
    var _SERIF_FONT              = "Times";
    // --- /usr/share/fonts/TTF/DejaVuSeri*.ttf -------
//  var _SERIF_FONT              = "DejaVu Serif";
    // --- /usr/share/fonts/TTF/LiberationSeri*.ttf ---
//  var _SERIF_FONT              = "Liberation Serif";
    // ------------------------------------------------------------------------
    var _ARCH_HEADER             = "Arch";
    var _REPO_HEADER             = "Repo";
    var _NAME_HEADER             = "Name";
    var _VERSION_HEADER          = "Version";
    var _LAST_UPDATED_HEADER     = "Last Updated";
    var _FLAG_DATE_HEADER        = "Flag Date";
    // ------------------------------------------------------------------------
    var _ROWS_IN_SET_FOOTER      = " rows in set";
    var _ROWS_SHOWN_FOOTER       = "  (" + MAX_ROWS_IN_A_PAGE + " rows shown)";
    var _PDF_REPORT_SAVED_MSG    = "PDF report saved";

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

        var report = _report.getContext(_2D);

        var pdf_stream = _report.createPDFStream();
        var pdf_report = fs.createWriteStream(pdf_report_path);

        // --- Report version -------------------------------------------------
        /*
         * Note: The possibility to set the PDF version is not implemented
         *       currently in the "canvas" npm package. Though in the Cairo
         *       library it is. See for example the appropriate Vala call:
         *
         *       _report.restrict_to_version(PdfVersion.VERSION_1_4);
         *
         *       (It is silently hardcoded to be of version 1.5.)
         */
//      _report.restrictToVersion(Canvas.VERSION_1_4);

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
//      _report.setMetadata(Canvas.TITLE,    _REPORT_TITLE   );
//      _report.setMetadata(Canvas.AUTHOR,   _REPORT_AUTHOR  );
//      _report.setMetadata(Canvas.SUBJECT,  _REPORT_SUBJECT );
//      _report.setMetadata(Canvas.KEYWORDS, _REPORT_KEYWORDS);
//      _report.setMetadata(Canvas.CREATOR,  _REPORT_CREATOR );

        /*
         * Attaching the Writable stream to the Readable stream
         * and pushing all of its data to the attached one, i.e.:
         *              (W) pdf_report   <==   (R) pdf_stream
         */
        pdf_stream.pipe(pdf_report);

        // --- Page body (data) x MAX_PAGES -----------------------------------
        for (var i = 0; i < MAX_PAGES; i++) {
            ret = _page_body_draw(report,     hdr_set,     row_set,
                                          num_hdrs,    num_rows,    aux);

            if (ret === aux._EXIT_FAILURE) {
                console.log(__name__ + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                                     + aux._COLON_SPACE_SEP
                                     + aux._ERROR_NO_REPORT_GEN);

                return ret;
            }

            report.addPage();
        }

        console.log(_PDF_REPORT_SAVED_MSG + aux._COLON_SPACE_SEP
                                          + pdf_report_path);
        // --------------------------------------------------------------------
        // --- Generating the PDF report - End --------------------------------
        // --------------------------------------------------------------------

        return ret;
    };

    /* Draws the PDF report page body (data). */
    var _page_body_draw = function(report,     hdr_set,     row_set,
                                           num_hdrs,    num_rows,    aux) {

        var ret = aux._EXIT_SUCCESS;

        // --- Border ---------------------------------------------------------

        report._setStrokeColor(_RAINY_NIGHT_COLOR);

        report.lineWidth = 2;

        report.strokeRect((16 / MM), (19 / MM), (178 / MM), (259 / MM));

        // --- Headers bar ----------------------------------------------------

        report._setFillColor(_RAINY_NIGHT_COLOR);

        report.fillRect((              17  / MM),
                        (((ZZ - 10) - 267) / MM),
                        (             176  / MM),
                        (              10  / MM));

        // --- Headers txt ----------------------------------------------------

        report._setFont(_PANGO_WEIGHT_SEMIBOLD, aux._EMPTY_STRING, (16 / PT),
                                                aux._EMPTY_STRING, _SANS_FONT);

        report._setFillColor(_WHITE_COLOR);

        hdr_set = [
            _ARCH_HEADER,
            _REPO_HEADER,
            _NAME_HEADER,
            _VERSION_HEADER,
            _LAST_UPDATED_HEADER,
            _FLAG_DATE_HEADER,
        ];

        var x = 0;

        // Printing table headers.
        for (var i = 0; i < num_hdrs; i++) {
                   if (i === 1) {
                x =  17;
            } else if (i === 2) {
                x =  40;
            } else if (i === 3) {
                x =  78;
            } else if (i === 4) {
                x = 107;
            } else if (i === 5) {
                x = 146;
            } else { // <== Includes (i === 0).
                x =   0;
            }

            report.fillText(hdr_set[i], ((20 +   x) / MM), ((ZZ - 270) / MM));
        }

        // --- Table rows -----------------------------------------------------

        report._setFont(_PANGO_WEIGHT_NORMAL, aux._EMPTY_STRING, (11 / PT),
                                              aux._EMPTY_STRING, _SANS_FONT);

        var y = 0;

        // Printing table rows.
//      for (var i = 0; i <           num_rows; i++) {
        for (var i = 0; i < MAX_ROWS_IN_A_PAGE; i++) {
            if ((i & 1) === 1) {
                report._setFillColor(_RAINY_DAY_COLOR);

                report.fillRect((              17       / MM),
                                (((ZZ - 6) - (260 - y)) / MM),
                                (             176       / MM),
                                (               6       / MM));
            }

            report._setFillColor(_BLACK_COLOR);

            for (var j = 0; j < num_hdrs; j++) {
                       if (j === 1) {
                    x =  17;
                } else if (j === 2) {
                    x =  40;
                } else if (j === 3) {
                    x =  78;
                } else if (j === 4) {
                    x = 123;
                } else if (j === 5) {
                    x = 148;
                } else { // <== Includes (j === 0).
                    x =   0;
                }

                report.fillText(row_set[i][j], ((20 +        x ) / MM),
                                               ((ZZ - (262 - y)) / MM));
            }

            y += 6;
        }

        // --- Footer bar -----------------------------------------------------

        report._setFillColor(_VERY_LIGHT_COBALT_COLOR);

        report.fillRect((            17  / MM),
                        (((ZZ - 6) - 20) / MM),
                        (           176  / MM),
                        (             6  / MM));

        // --- Footer txt -----------------------------------------------------

        report._setFont(_PANGO_WEIGHT_SEMIBOLD,aux._EMPTY_STRING, (12 / PT),
                                               aux._EMPTY_STRING, _SERIF_FONT);

        report._setFillColor(_YET_NOT_WHITE_COLOR);

        report.fillText(num_rows + _ROWS_IN_SET_FOOTER + _ROWS_SHOWN_FOOTER,
                                               (20 / MM), ((ZZ - 22) / MM));

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

// vim:set nu et ts=4 sw=4:

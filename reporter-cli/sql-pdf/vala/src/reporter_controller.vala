/*
 * reporter-cli/sql-pdf/vala/src/reporter_controller.vala
 * ============================================================================
 * Reporter Multilang. Version 0.1
 * ============================================================================
 * A tool to generate human-readable reports based on data from various sources
 * with the focus on its implementation using a series of programming languages
 * ============================================================================
 * Written by Radislav (Radicchio) Golubtsov, 2016-2019
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

   #if (MYSQL)
    using Mysql;
 #elif (POSTGRES)
    using Postgres;
 #elif (SQLITE)
    using Sqlite;
#endif

using Cairo;

namespace CliSqlPdf {
/** The controller class of the application. */
class ReporterController {
    /**
     * Constant: The start date to retrieve data set.
     *     TODO: Move to cli args.
     */
    const string FROM = "2016-06-01";

    /**
     * Constant: The end   date to retrieve data set.
     *     TODO: Move to cli args.
     */
    const string TO   = "2016-12-01";

    /**
     * Constant: The PDF report output location.
     *     TODO: Move to cli args.
     */
    const string PDF_REPORT_DIR = "lib/data";

    /**
     * Constant: The PDF report filename.
     *     TODO: Move to cli args.
     */
    const string PDF_REPORT_FILENAME = "packages.pdf";

    /**
     * Constant: The number of pages generated in a PDF report.
     *     TODO: Move to cli args.
     */
    const uint MAX_PAGES = 20;

    /** Constant: The maximum number of data rows displayed in a page. */
    const uint MAX_ROWS_IN_A_PAGE = 40;

    /** Constant: The PDF basic measurement unit -- PostScript point. */
    const uint   PT =   1;

    /** Constant: The one inch       (in PDF measurement terms). */
    const double IN = ( 1   / 72);

    /** Constant: The one millimeter (in PDF measurement terms). */
    const double MM = (25.4 / 72);

    /** Constant: The RGB normalizing divisor. */
    const double FF = 255;

    /** Constant: The vertical coordinate flipping normalizer. */
    const uint   ZZ = 297;

    /* Various string literals. */
    const string _REPORT_TITLE         = "Arch Linux Packages";
    const string _REPORT_AUTHOR        = "Arch Linux Package Maintainers";
    const string _REPORT_SUBJECT       = "Sample list of Arch Linux packages.";
    const string _REPORT_KEYWORDS      = "Linux ArchLinux Packages Arch Repo "
                                       + "core extra community multilib";
    const string _REPORT_CREATOR       = "Reporter Multilang 0.1 - "
                                       + "https://github.com/rgolubtsov/"
                                       + "reporter-multilang";
    // ------------------------------------------------------------------------
    // --- /usr/share/fonts/100dpi/helv*.pcf.gz ------------
//  const string _SANS_FONT            = "Helvetica";
    // --- /usr/share/fonts/TTF/DejaVuSan*.ttf -------------
//  const string _SANS_FONT            = "DejaVu Sans";
    // --- /usr/share/fonts/TTF/LiberationSan*.ttf ---------
    const string _SANS_FONT            = "Liberation Sans";
    // --- /usr/share/fonts/100dpi/tim*.pcf.gz -------------
//  const string _SERIF_FONT           = "Times";
    // --- /usr/share/fonts/TTF/DejaVuSeri*.ttf ------------
//  const string _SERIF_FONT           = "DejaVu Serif";
    // --- /usr/share/fonts/TTF/LiberationSeri*.ttf --------
    const string _SERIF_FONT           = "Liberation Serif";
    // ------------------------------------------------------------------------
    const string _ARCH_HEADER          = "Arch";
    const string _REPO_HEADER          = "Repo";
    const string _NAME_HEADER          = "Name";
    const string _VERSION_HEADER       = "Version";
    const string _LAST_UPDATED_HEADER  = "Last Updated";
    const string _FLAG_DATE_HEADER     = "Flag Date";
    // ------------------------------------------------------------------------
    const string _ROWS_IN_SET_FOOTER   = " rows in set";
    const string _ROWS_SHOWN_FOOTER_1  = "  (";
    const string _ROWS_SHOWN_FOOTER_2  = " rows shown)";
    const string _PDF_REPORT_SAVED_MSG = "PDF report saved";

    /**
     * Generates the PDF report.
     *
     * @param dbcnx The database handle object.
     * @param exec  The executable path.
     *
     * @return The exit code indicating the status
     *         of generating the PDF report.
     */
    public int pdf_report_generate(Database dbcnx, string exec) {
        int ret = Posix.EXIT_SUCCESS;

        string __name__ = typeof(ReporterController).name();

        // Instantiating the controller helper class.
        var aux = new ControllerHelper();

        var __file__ = exec;

        // Instantiating the model class.
        var model = new ReporterModel();

        string[] hdr_set = {};

        // Retrieving a list of all data items stored in the database.
//      string[,] row_set = model.get_all_data_items(dbcnx, out(hdr_set));

        // Retrieving a list of data items for a given date period.
        string[,] row_set = model.get_data_items_by_date(FROM, TO,
                                                     dbcnx, out(hdr_set));

        var num_rows = row_set.length[0];
        var num_hdrs = row_set.length[1];

        // In case of getting an empty result set, informing the user.
        if (num_hdrs == 0) {
            ret = Posix.EXIT_FAILURE;

            stdout.printf(aux.S_FMT, __name__
                        + aux.COLON_SPACE_SEP + aux.ERROR_PREFIX
                        + aux.COLON_SPACE_SEP + aux.ERROR_NO_DATA
                                              + aux.NEW_LINE);

            return ret;
        }

        // --------------------------------------------------------------------
        // --- Debug output - Begin -------------------------------------------
        // --------------------------------------------------------------------
        var dbg_output = new TabularDisplay(hdr_set);

        dbg_output.populate(row_set);

        stdout.printf(aux.S_FMT, dbg_output.render());

        stdout.printf(aux.S_FMT, num_rows.to_string() + _ROWS_IN_SET_FOOTER
                                       + aux.NEW_LINE + aux.NEW_LINE);
        // --------------------------------------------------------------------
        // --- Debug output - End ---------------------------------------------
        // --------------------------------------------------------------------

        Posix.sleep(1); // <== Waiting one second...just for fun...:-)...-- OK.

        // --------------------------------------------------------------------
        // --- Generating the PDF report - Begin ------------------------------
        // --------------------------------------------------------------------
        var pdf_report_path = _get_pdf_report_path(__file__, aux);

        var _report = new PdfSurface(pdf_report_path, (210 / MM), (297 / MM));

        _report.restrict_to_version(PdfVersion.VERSION_1_4);

        // --- Report metadata ------------------------------------------------
        /*
         * Note: The possibility to inject PDF metadata entries has appeared
         *       in Cairo 1.16, but even in Arch Linux the "cairo" package
         *       currently is just of version 1.14.8. And, of course, its Vala
         *       bindings are in the same state. After upgrading to Cairo 1.16+
         *       appropriate calls should look something like the given below
         *       (commented out for now).
         *
         * See for reference:
         *   - Cairo sources:
         *       https://cgit.freedesktop.org/cairo/tree/src/cairo-pdf.h
         *       https://cgit.freedesktop.org/cairo/tree/src/
         *                                           cairo-pdf-surface.c
         *
         *   - Cairo Valadoc:
         *       https://valadoc.org/cairo/Cairo.PdfSurface.html
         */
//      _report.set_metadata(PdfMetadata.TITLE,    _REPORT_TITLE   );
//      _report.set_metadata(PdfMetadata.AUTHOR,   _REPORT_AUTHOR  );
//      _report.set_metadata(PdfMetadata.SUBJECT,  _REPORT_SUBJECT );
//      _report.set_metadata(PdfMetadata.KEYWORDS, _REPORT_KEYWORDS);
//      _report.set_metadata(PdfMetadata.CREATOR,  _REPORT_CREATOR );

        var report = new Cairo.Context(_report);

        // --- Page body (data) x MAX_PAGES -----------------------------------
        for (uint i = 0; i < MAX_PAGES; i++) {
            ret=_page_body_draw(report, hdr_set, row_set, num_hdrs, num_rows);

            if (ret == Posix.EXIT_FAILURE) {
                stdout.printf(aux.S_FMT, __name__
                            + aux.COLON_SPACE_SEP + aux.ERROR_PREFIX
                            + aux.COLON_SPACE_SEP + aux.ERROR_NO_REPORT_GEN
                                                  + aux.NEW_LINE);

                return ret;
            }

            report.show_page();
        }

        stdout.printf(aux.S_FMT, _PDF_REPORT_SAVED_MSG + aux.COLON_SPACE_SEP
                                + pdf_report_path      + aux.NEW_LINE);
        // --------------------------------------------------------------------
        // --- Generating the PDF report - End --------------------------------
        // --------------------------------------------------------------------

        return ret;
    }

    /* Draws the PDF report page body (data). */
    int _page_body_draw(Cairo.Context report,
                        string[ ]     hdr_set,
                        string[,]     row_set,
                        uint          num_hdrs,
                        uint          num_rows) {

        int ret = Posix.EXIT_SUCCESS;

        HashTable<string, string> table_headers
                          = new HashTable<string, string>(str_hash, str_equal);

        /*
         * Note: Without having this coordinate system translation
         *       it needs to utilize the vertical coordinate flipping
         *       normalizer (ZZ) to flip its y-coordinate where applicable.
         *    Q: What is it for? -- A: When using Cairo text API,
         *       it's quite sufficient to use the coordinate system
         *       translation. But when using Pango text API on top of Cairo,
         *       ZZ should be used instead.
         */
//      report.translate((0 / MM), (297 / MM)); report.scale(1, -1);

        // --- Border ---------------------------------------------------------

        report.set_source_rgb(( 34 / FF),             // <== _RAINY_NIGHT_COLOR
                              ( 68 / FF),             //              (#224488)
                              (136 / FF));

        report.rectangle((16 / MM), (19 / MM), (178 / MM), (259 / MM));

        report.stroke();

        // --- Headers bar ----------------------------------------------------

        report.set_source_rgb(( 34 / FF),             // <== _RAINY_NIGHT_COLOR
                              ( 68 / FF),             //              (#224488)
                              (136 / FF));

        report.rectangle((              17  / MM),
                         (((ZZ - 10) - 267) / MM),
                         (             176  / MM),
                         (              10  / MM));

        report.fill();

        // --- Headers txt ----------------------------------------------------

        var font_descr = new Pango.FontDescription();

        font_descr.set_family(_SANS_FONT);

        font_descr.set_size((int)((12 / PT) * Pango.SCALE));

        font_descr.set_weight(Pango.Weight.SEMIBOLD);

        var layout = Pango.cairo_create_layout(report);

        layout.set_font_description(font_descr);

        // For Cairo-only output.
//      report.select_font_face(_SANS_FONT, FontSlant.NORMAL,
//                                          FontWeight.BOLD);
//      report.set_font_size((16 / PT));
//      var font_matrix = new Matrix.identity();
//      report.get_font_matrix(out(font_matrix)); font_matrix.scale(1, -1);
//      report.set_font_matrix(font_matrix);

        report.set_source_rgb((255 / FF),                   // <== _WHITE_COLOR
                              (255 / FF),                   //        (#ffffff)
                              (255 / FF));

        table_headers.insert(hdr_set[0], _ARCH_HEADER);
        table_headers.insert(hdr_set[1], _REPO_HEADER);
        table_headers.insert(hdr_set[2], _NAME_HEADER);
        table_headers.insert(hdr_set[3], _VERSION_HEADER);
        table_headers.insert(hdr_set[4], _LAST_UPDATED_HEADER);
        table_headers.insert(hdr_set[5], _FLAG_DATE_HEADER);

        uint x = 0;

        // Printing table headers.
        for (uint i = 0; i < num_hdrs; i++) {
                   if (i == 1) {
                x =  17;
            } else if (i == 2) {
                x =  40;
            } else if (i == 3) {
                x =  78;
            } else if (i == 4) {
                x = 107;
            } else if (i == 5) {
                x = 146;
            } else { // <== Includes (i == 0).
                x =   0;
            }

            report.move_to(((20 + x) / MM), ((ZZ - 270) / MM));

            // Cairo-only output.
//          report.show_text(table_headers.lookup(hdr_set[i]));

            // Pango/Cairo output.
            // See for ref.: https://www.cairographics.org/FAQ/#using_pango .
            layout.set_text(table_headers.lookup(hdr_set[i]), -1);
            Pango.cairo_show_layout_line(report, layout.get_line_readonly(0));
        }

        // --- Table rows -----------------------------------------------------

        font_descr.set_size((int)((8 / PT) * Pango.SCALE));

        font_descr.set_weight(Pango.Weight.NORMAL);

        layout.set_font_description(font_descr);

        // For Cairo-only output.
//      report.select_font_face(_SANS_FONT, FontSlant.NORMAL,
//                                          FontWeight.NORMAL);
//      report.set_font_size((11 / PT));
//      report.get_font_matrix(out(font_matrix)); font_matrix.scale(1, -1);
//      report.set_font_matrix(font_matrix);

        uint y = 0;

        // Printing table rows.
//      for (uint i = 0; i <           num_rows; i++) {
        for (uint i = 0; i < MAX_ROWS_IN_A_PAGE; i++) {
            if ((i & 1) == 1) {
                report.set_source_rgb((221 / FF),       // <== _RAINY_DAY_COLOR
                                      (221 / FF),       //            (#dddddd)
                                      (221 / FF));

                report.rectangle((              17       / MM),
                                 (((ZZ - 6) - (260 - y)) / MM),
                                 (             176       / MM),
                                 (               6       / MM));

                report.fill();
            }

            report.set_source_rgb((0 / FF),                 // <== _BLACK_COLOR
                                  (0 / FF),                 //        (#000000)
                                  (0 / FF));

            for (uint j = 0; j < num_hdrs; j++) {
                       if (j == 1) {
                    x =  17;
                } else if (j == 2) {
                    x =  40;
                } else if (j == 3) {
                    x =  78;
                } else if (j == 4) {
                    x = 123;
                } else if (j == 5) {
                    x = 148;
                } else { // <== Includes (j == 0).
                    x =   0;
                }

                report.move_to(((20 + x) / MM), ((ZZ - (262 - y)) / MM));

                // Cairo-only output.
//              report.show_text(row_set[i,j]);

                // Pango/Cairo output.
                layout.set_text(row_set[i,j], -1);
                Pango.cairo_show_layout_line(report,
                                             layout.get_line_readonly(0));
            }

            y += 6;
        }

        // --- Footer bar -----------------------------------------------------

        report.set_source_rgb((170 / FF),       // <== _VERY_LIGHT_COBALT_COLOR
                              (170 / FF),       //                    (#aaaaaa)
                              (170 / FF));

        report.rectangle((            17  / MM),
                         (((ZZ - 6) - 20) / MM),
                         (           176  / MM),
                         (             6  / MM));

        report.fill();

        // --- Footer txt -----------------------------------------------------

        font_descr.set_family(_SERIF_FONT);

        font_descr.set_size((int)((9 / PT) * Pango.SCALE));

        font_descr.set_weight(Pango.Weight.SEMIBOLD);

        layout.set_font_description(font_descr);

        // For Cairo-only output.
//      report.select_font_face(_SERIF_FONT, FontSlant.NORMAL,
//                                           FontWeight.BOLD);
//      report.set_font_size((12 / PT));
//      report.get_font_matrix(out(font_matrix)); font_matrix.scale(1, -1);
//      report.set_font_matrix(font_matrix);

        report.set_source_rgb((238 / FF),           // <== _YET_NOT_WHITE_COLOR
                              (238 / FF),           //                (#eeeeee)
                              (238 / FF));

        report.move_to((20 / MM), ((ZZ - 22) / MM));

        // Cairo-only output.
//      report.show_text(num_rows.to_string() + _ROWS_IN_SET_FOOTER
//                     + _ROWS_SHOWN_FOOTER_1 + MAX_ROWS_IN_A_PAGE.to_string()
//                     + _ROWS_SHOWN_FOOTER_2);

        // Pango/Cairo output.
        layout.set_text(num_rows.to_string() + _ROWS_IN_SET_FOOTER
                      + _ROWS_SHOWN_FOOTER_1 + MAX_ROWS_IN_A_PAGE.to_string()
                      + _ROWS_SHOWN_FOOTER_2, -1);
        Pango.cairo_show_layout_line(report, layout.get_line_readonly(0));

        // --------------------------------------------------------------------

        return ret;
    }

    /*
     * Helper method.
     * Returns the generated PDF report output path,
     * relative to the executable's location.
     * TODO: Remove this method when the report output location
     *       will be passed through cli args.
     */
    string _get_pdf_report_path(string exec, ControllerHelper aux) {
        var exec_path = exec.split(aux.SLASH);

//      for (uint i = 0; i < exec_path.length; i++) {
//          stdout.printf(aux.S_FMT, exec_path[i] + aux.NEW_LINE);
//      }

        exec_path.resize(exec_path.length - 1);
        exec_path       [exec_path.length - 1] = PDF_REPORT_DIR;

//      for (uint i = 0; i < exec_path.length; i++) {
//          stdout.printf(aux.S_FMT, exec_path[i] + aux.NEW_LINE);
//      }

        var pdf_report_path = string.joinv(aux.SLASH, exec_path)
                                         + aux.SLASH + PDF_REPORT_FILENAME;

        return pdf_report_path;
    }

    /** Default constructor. */
    public ReporterController() {}
}
} // namespace CliSqlPdf

// vim:set nu et ts=4 sw=4:

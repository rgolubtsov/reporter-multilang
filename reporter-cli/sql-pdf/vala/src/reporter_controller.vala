/*
 * reporter-cli/sql-pdf/vala/src/reporter_controller.vala
 * ============================================================================
 * Reporter Multilang. Version 0.1
 * ============================================================================
 * A tool to generate human-readable reports based on data from various sources
 * with the focus on its implementation using a series of programming languages
 * ============================================================================
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

    /* Various string literals. */
    const string _ROWS_IN_SET_FOOTER   = " rows in set";
    const string _ROWS_SHOWN_FOOTER_1  = "  (";
    const string _ROWS_SHOWN_FOOTER_2  = " rows shown)";
    const string _PDF_REPORT_SAVED_MSG = "PDF report saved";

    /**
     * Generates the PDF report.
     *
     * @param dbcnx The database handle object.
     * @param exec  The executable path.

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

            stdout.printf(aux._S_FMT, __name__
                        + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                        + aux._COLON_SPACE_SEP + aux._ERROR_NO_DATA
                                               + aux._NEW_LINE);

            return ret;
        }

        // --------------------------------------------------------------------
        // --- Debug output - Begin -------------------------------------------
        // --------------------------------------------------------------------
        var dbg_output = new TabularDisplay(hdr_set);

        dbg_output.populate(row_set);

        stdout.printf(aux._S_FMT, dbg_output.render());

        stdout.printf(aux._S_FMT, num_rows.to_string() + _ROWS_IN_SET_FOOTER
                                       + aux._NEW_LINE + aux._NEW_LINE);
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

        var report = new Cairo.Context(_report);

        // --- Page body (data) -----------------------------------------------
        ret = _page_body_draw(report, hdr_set, row_set);
        // --------------------------------------------------------------------
        // --- Generating the PDF report - End --------------------------------
        // --------------------------------------------------------------------

        return ret;
    }

    /* Draws the PDF report page body (data). */
    int _page_body_draw(Cairo.Context report,
                        string[ ]     hdr_set,
                        string[,]     row_set) {

        int ret = Posix.EXIT_SUCCESS;

        // TODO: Implement drawing the PDF report page body.

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
        var exec_path = exec.split(aux._SLASH);

//      for (uint i = 0; i < exec_path.length; i++) {
//          stdout.printf(aux._S_FMT, exec_path[i] + aux._NEW_LINE);
//      }

        exec_path.resize(exec_path.length - 1);
        exec_path       [exec_path.length - 1] = PDF_REPORT_DIR;

//      for (uint i = 0; i < exec_path.length; i++) {
//          stdout.printf(aux._S_FMT, exec_path[i] + aux._NEW_LINE);
//      }

        var pdf_report_path = string.joinv(aux._SLASH, exec_path)
                                         + aux._SLASH + PDF_REPORT_FILENAME;

        return pdf_report_path;
    }

    /** Default constructor. */
    public ReporterController() {}
}

} // namespace CliSqlPdf

// vim:set nu:et:ts=4:sw=4:

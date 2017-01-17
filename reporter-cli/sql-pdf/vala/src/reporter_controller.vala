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
    const string PDF_REPORT_DIR = "data";

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

    /**
     * Generates the PDF report.
     *
     * @param dbcnx The database handle object.
     *
     * @return The exit code indicating the status
     *         of generating the PDF report.
     */
    public int pdf_report_generate(Database dbcnx) {
        int ret = Posix.EXIT_SUCCESS;

        string __name__ = typeof(ReporterController).name();

        // Instantiating the controller helper class.
        var aux = new ControllerHelper();

        // Instantiating the model class.
        var model = new ReporterModel();

        string[] hdr_set = {};

        // Retrieving a list of all data items stored in the database.
        string[] row_set = model.get_all_data_items(dbcnx, out(hdr_set));

        // Retrieving a list of data items for a given date period.
//      string[] row_set = model.get_data_items_by_date(FROM, TO,
//                                                  dbcnx, out(hdr_set));

        // In case of getting an empty result set, informing the user.
//      if (row_set.length == 0) {
        if (row_set.length  > 0) {
            ret = Posix.EXIT_FAILURE;

            stdout.printf(aux._S_FMT, __name__
                        + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                        + aux._COLON_SPACE_SEP + aux._ERROR_NO_DATA
                                               + aux._NEW_LINE);

            return ret;
        }

        // --------------------------------------------------------------------
        // -- Debug output - Begin --------------------------------------------
        // --------------------------------------------------------------------
        // TODO: Implement printing debug info.
        // --------------------------------------------------------------------
        // -- Debug output - End ----------------------------------------------
        // --------------------------------------------------------------------

        Posix.sleep(1); // <== Waiting one second...just for fun...:-)...-- OK.

        // --------------------------------------------------------------------
        // -- Generating the PDF report - Begin -------------------------------
        // --------------------------------------------------------------------
        // TODO: Implement generating the PDF report.
        // --------------------------------------------------------------------
        // -- Generating the PDF report - End ---------------------------------
        // --------------------------------------------------------------------

        return ret;
    }

    /** Default constructor. */
    public ReporterController() {}
}

} // namespace CliSqlPdf

// vim:set nu:et:ts=4:sw=4:

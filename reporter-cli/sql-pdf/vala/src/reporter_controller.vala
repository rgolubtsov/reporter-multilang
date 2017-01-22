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

    /* Various string literals. */
    const string _ROWS_IN_SET_FOOTER   = " rows in set";
    const string _ROWS_SHOWN_FOOTER_1  = "  (";
    const string _ROWS_SHOWN_FOOTER_2  = " rows shown)";
    const string _PDF_REPORT_SAVED_MSG = "PDF report saved";

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
        // -- Debug output - Begin --------------------------------------------
        // --------------------------------------------------------------------
        uint[ ] hdr_set_len = new uint[         num_hdrs];
        uint[,] row_set_len = new uint[num_rows,num_hdrs];
        uint[ ] col_max_len = new uint[num_rows         ];

        // Searching for the max data length in each column to form its width.
        for (uint j = 0; j < num_hdrs; j++) {
            hdr_set_len[j] = hdr_set[j].length;

            for (uint i = 0; i < num_rows; i++) {
                row_set_len[i,j] = row_set[i,j].length;
            }

            col_max_len[j] = row_set_len[0,j]; // <== Assuming this is the max.

            // Searching for the max element in a column.
            for (uint i = 0; i < num_rows; i++) {
                if (row_set_len[i,j] > col_max_len[j]) {
                    col_max_len[j] = row_set_len[i,j];
                }
            }
        }

        _separator_draw(num_hdrs, hdr_set_len, col_max_len, aux);

        // Printing table headers.
        for (uint i = 0; i < num_hdrs; i++) {
            stdout.printf(aux._S_FMT, aux._V_BAR + aux._SPACE + hdr_set[i]);

            uint spacers = 0;

            if (hdr_set_len[i] < col_max_len[i]) {
                spacers = col_max_len[i] - hdr_set_len[i];
            }

            spacers++; // <== Additional spacer (padding).

            for (uint m = 0; m < spacers; m++) {
                stdout.printf(aux._S_FMT, aux._SPACE);
            }
        }

        stdout.printf(aux._S_FMT, aux._V_BAR + aux._NEW_LINE);

        _separator_draw(num_hdrs, hdr_set_len, col_max_len, aux);

        // Printing table rows.
        for (uint i = 0; i < num_rows; i++) {
            for (uint j = 0; j < num_hdrs; j++) {
                stdout.printf(aux._S_FMT, aux._V_BAR+aux._SPACE+row_set[i,j]);

                if (col_max_len[j] < hdr_set_len[j]) {
                    col_max_len[j] = hdr_set_len[j];
                }

                uint spacers = 0;

                if (row_set_len[i,j] < col_max_len[j]) {
                    spacers = col_max_len[j] - row_set_len[i,j];
                }

                spacers++; // <== Additional spacer (padding).

                for (uint m = 0; m < spacers; m++) {
                    stdout.printf(aux._S_FMT, aux._SPACE);
                }
            }

            stdout.printf(aux._S_FMT, aux._V_BAR + aux._NEW_LINE);
        }

        _separator_draw(num_hdrs, hdr_set_len, col_max_len, aux);

        stdout.printf(aux._S_FMT, num_rows.to_string() + _ROWS_IN_SET_FOOTER
                                       + aux._NEW_LINE + aux._NEW_LINE);
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

    /* Helper method. Draws a horizontal separator for a table. */
    void _separator_draw(uint             num_hdrs,
                         uint[]           hdr_set_len,
                         uint[]           col_max_len,
                         ControllerHelper aux) {

        for (uint i = 0; i < num_hdrs; i++) {
            stdout.printf(aux._S_FMT, aux._SEP_NOD);

            uint sep_len = hdr_set_len[i];

            if (sep_len < col_max_len[i]) {
                sep_len = col_max_len[i];
            }

            sep_len += 2; // <== Two additional separator cogs (padding).

            for (uint m = 0; m < sep_len; m++) {
                stdout.printf(aux._S_FMT, aux._SEP_COG);
            }
        }

        stdout.printf(aux._S_FMT, aux._SEP_NOD + aux._NEW_LINE);
    }

    /** Default constructor. */
    public ReporterController() {}
}

} // namespace CliSqlPdf

// vim:set nu:et:ts=4:sw=4:

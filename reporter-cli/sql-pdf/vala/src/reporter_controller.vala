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

namespace CliSqlPdf {

/** The controller class of the application. */
class ReporterController {
    /*
     * Constant: The start date to retrieve data set.
     *     TODO: Move to cli args.
     *
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
    const uint PT =   1;

    /** Constant: The one inch       (in PDF measurement terms). */
    const double IN = ( 1   / 72);

    /** Constant: The one millimeter (in PDF measurement terms). */
    const double MM = (25.4 / 72);

    // TODO: Implement remaining stuff :-).

    /** Default constructor. */
    public ReporterController() {}
}

} // namespace CliSqlPdf

// vim:set nu:et:ts=4:sw=4:

/*
 * reporter-cli/sql-pdf/go/src/reporter_controller.go
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

package main

import "database/sql"
import "reflect"
import "fmt"
import "strconv"
import "time"
import "strings"
import "github.com/jung-kurt/gofpdf"

/**
 * Constant: The start date to retrieve data set.
 *     TODO: Move to cli args.
 */
const FROM string = "2016-06-01"

/**
 * Constant: The end   date to retrieve data set.
 *     TODO: Move to cli args.
 */
const TO   string = "2016-12-01"

/**
 * Constant: The PDF report output location.
 *     TODO: Move to cli args.
 */
const PDF_REPORT_DIR string = "lib/data"

/**
 * Constant: The PDF report filename.
 *     TODO: Move to cli args.
 */
const PDF_REPORT_FILENAME string = "packages.pdf"

/** Constant: The PDF basic measurement unit -- PostScript point. */
const PT uint    =   1

/** Constant: The one inch       (in PDF measurement terms). */
const IN float64 = ( 1   / 72)

/** Constant: The one millimeter (in PDF measurement terms). */
const MM float64 = (25.4 / 72)

/* Various string literals. */
const _REPORT_ORIENTATION_P string = "Portrait"
const _REPORT_UNITS_MM      string = "mm"
const _REPORT_PAGE_SIZE_A4  string = "A4"
// ----------------------------------------------------------------------------
const _ARCH_HEADER          string = "Arch"
const _REPO_HEADER          string = "Repo"
const _NAME_HEADER          string = "Name"
const _VERSION_HEADER       string = "Version"
const _LAST_UPDATED_HEADER  string = "Last Updated"
const _FLAG_DATE_HEADER     string = "Flag Date"
// ----------------------------------------------------------------------------
const _ROWS_IN_SET_FOOTER   string = " rows in set"
const _ROWS_SHOWN_FOOTER_1  string = "  ("
const _ROWS_SHOWN_FOOTER_2  string = " rows shown)"
const _PDF_REPORT_SAVED_MSG string = "PDF report saved"

/** The controller class of the application. */
type ReporterController struct {
    /*
     * Attached methods:
     *   - pdf_report_generate(cnx      *sql.DB,
     *                         postgres  bool,
     *                         exec      string) int
     *
     *   - _page_body_draw(report      *gofpdf.Fpdf,
     *                     hdr_set  [  ]string,
     *                     row_set  [][]string,
     *                     num_hdrs     uint,
     *                     num_rows     uint) int
     *
     *   - _get_pdf_report_path(exec string) string
     */
}

/**
 * Generates the PDF report.
 *
 * @param cnx      The database connection object.
 * @param postgres The indicator that shows whether the database connection
 *                 object is PostgreSQL connection.
 * @param exec     The executable path.
 *
 * @return The exit code indicating the status of generating the PDF report.
 */
func (ReporterController) pdf_report_generate(cnx      *sql.DB,
                                              postgres  bool,
                                              exec      string) int {

    var ret int = _EXIT_SUCCESS

    var class___ ReporterController
    var __name__ string = reflect.TypeOf(class___).Name()

    __file__ := exec

    var e error

    // Instantiating the model class.
    model := new(ReporterModel)

    // Retrieving a list of all data items stored in the database.
//  hdr_set, row_set := model.get_all_data_items(cnx)

    // Retrieving a list of data items for a given date period.
    hdr_set, row_set := model.get_data_items_by_date(FROM, TO, cnx, postgres)

    num_hdrs := uint(len(hdr_set))
    num_rows := uint(len(row_set))

    // In case of getting an empty result set, informing the user.
    if (num_hdrs == 0) {
        ret = _EXIT_FAILURE

        fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + _ERROR_PREFIX +
                                      _COLON_SPACE_SEP + _ERROR_NO_DATA +
                                                         _NEW_LINE)

        return ret
    }

    // ------------------------------------------------------------------------
    // --- Debug output - Begin -----------------------------------------------
    // ------------------------------------------------------------------------
    dbg_output := new(TabularDisplay)

    fmt.Printf(_S_FMT, dbg_output.render(hdr_set, row_set))

    fmt.Printf(_S_FMT, strconv.Itoa(int(num_rows)) + _ROWS_IN_SET_FOOTER +
                                         _NEW_LINE + _NEW_LINE)
    // ------------------------------------------------------------------------
    // --- Debug output - End -------------------------------------------------
    // ------------------------------------------------------------------------

                            //     Waiting one second...
    time.Sleep(time.Second) // <== Just for fun...:-)...
                            //     Please!   --   OK.

    // ------------------------------------------------------------------------
    // --- Generating the PDF report - Begin ----------------------------------
    // ------------------------------------------------------------------------
    pdf_report_path := class___._get_pdf_report_path(__file__)

    report := gofpdf.New(_REPORT_ORIENTATION_P, // <== "Portrait".
                         _REPORT_UNITS_MM,
                         _REPORT_PAGE_SIZE_A4,  // <== 210 x 297 mm.
                         _EMPTY_STRING)

    // --- Page body (data) ---------------------------------------------------
    ret=class___._page_body_draw(report, hdr_set, row_set, num_hdrs, num_rows)

    // Trying to save the report.
    e = report.OutputFileAndClose(pdf_report_path)

    if (e != nil) {
        ret = _EXIT_FAILURE

        fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + _ERROR_PREFIX +
                                      _COLON_SPACE_SEP + e.Error() + _NEW_LINE)

        return ret
    }

    fmt.Printf(_S_FMT, _PDF_REPORT_SAVED_MSG + _COLON_SPACE_SEP +
                        pdf_report_path      + _NEW_LINE)
    // ------------------------------------------------------------------------
    // --- Generating the PDF report - End ------------------------------------
    // ------------------------------------------------------------------------

    return ret
}

/* Draws the PDF report page body (data). */
func (ReporterController) _page_body_draw(report      *gofpdf.Fpdf,
                                          hdr_set  [  ]string,
                                          row_set  [][]string,
                                          num_hdrs     uint,
                                          num_rows     uint) int {

    var ret int = _EXIT_SUCCESS

    // TODO: Implement drawing the PDF report page body.

    return ret
}

/*
 * Helper method.
 * Returns the generated PDF report output path,
 * relative to the executable's location.
 * TODO: Remove this method when the report output location
 *       will be passed through cli args.
 */
func (ReporterController) _get_pdf_report_path(exec string) string {
    exec_path := strings.Split(exec, _SLASH)

    var exec_path_len uint = uint(len(exec_path))

//  for i := uint(0); i < exec_path_len; i++ {
//      fmt.Printf(_S_FMT, exec_path[i] + _NEW_LINE)
//  }

    exec_path_new := make([]string, exec_path_len - 1)
    copy(exec_path_new, exec_path)
    exec_path_new[exec_path_len - 2] = PDF_REPORT_DIR

//  for i := uint(0); i < (exec_path_len - 1); i++ {
//      fmt.Printf(_S_FMT, exec_path_new[i] + _NEW_LINE)
//  }

    pdf_report_path := strings.Join(exec_path_new, _SLASH) + _SLASH +
                                                PDF_REPORT_FILENAME

    return pdf_report_path
}

// vim:set nu:et:ts=4:sw=4:

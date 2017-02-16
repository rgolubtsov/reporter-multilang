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

/**
 * Constant: The number of pages generated in a PDF report.
 *     TODO: Move to cli args.
 */
const MAX_PAGES uint = 20

/** Constant: The maximum number of data rows displayed in a page. */
const MAX_ROWS_IN_A_PAGE uint = 40

/** Constant: The PDF basic measurement unit -- PostScript point. */
const PT float64 =   1

/** Constant: The one inch       (in PDF measurement terms). */
const IN float64 = ( 1   / 72)

/** Constant: The one millimeter (in PDF measurement terms). */
const MM float64 = (25.4 / 72)

/** Constant: The vertical coordinate flipping normalizer. */
const ZZ float64 = 297

/* Various string literals. */
const _REPORT_ORIENTATION_P string = "Portrait"
const _REPORT_UNITS_MM      string = "mm"
const _REPORT_PAGE_SIZE_A4  string = "A4"
// ----------------------------------------------------------------------------
const _RECT_STYLE_DRAW      string = "D"
const _RECT_STYLE_FILL      string = "F"
const _FONT_STYLE_BOLD      string = "B"
const _HELVETICA_FONT       string = "Helvetica"
const _TIMES_FONT           string = "Times"
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

    // --- Page body (data) x MAX_PAGES ---------------------------------------
    for i := uint(0); i < MAX_PAGES; i++ {
        report.AddPage()

        ret=class___._page_body_draw(report,hdr_set,row_set,num_hdrs,num_rows)

        if (ret == _EXIT_FAILURE) {
            fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + _ERROR_PREFIX +
                       _COLON_SPACE_SEP + _ERROR_NO_REPORT_GEN + _NEW_LINE)

            return ret
        }
    }

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

    var table_headers map[string]string

    // --- Border -------------------------------------------------------------

    report.SetDrawColor(34, 68, 136)        // <== _RAINY_NIGHT_COLOR (#224488)

    report.SetLineWidth(0.7)

    report.Rect(16, 19, 178, 259, _RECT_STYLE_DRAW)

    // --- Headers bar --------------------------------------------------------

    report.SetFillColor(34, 68, 136)        // <== _RAINY_NIGHT_COLOR (#224488)

    report.Rect(17, ((ZZ - 10) - 267), 176, 10, _RECT_STYLE_FILL)

    // --- Headers txt --------------------------------------------------------

    report.SetFont(_HELVETICA_FONT, _FONT_STYLE_BOLD, (16 / PT))

    report.SetTextColor(255, 255, 255)            // <== _WHITE_COLOR (#ffffff)

    table_headers = make(map[string]string)

    table_headers[hdr_set[0]] = _ARCH_HEADER
    table_headers[hdr_set[1]] = _REPO_HEADER
    table_headers[hdr_set[2]] = _NAME_HEADER
    table_headers[hdr_set[3]] = _VERSION_HEADER
    table_headers[hdr_set[4]] = _LAST_UPDATED_HEADER
    table_headers[hdr_set[5]] = _FLAG_DATE_HEADER

    var x float64 = 0

    // Printing table headers.
    for i := uint(0); i < num_hdrs; i++ {
               if (i == 1) {
            x =  17
        } else if (i == 2) {
            x =  40
        } else if (i == 3) {
            x =  78
        } else if (i == 4) {
            x = 107
        } else if (i == 5) {
            x = 146
        } else { // <== Includes (i == 0).
            x =   0
        }

        report.Text((20 + x), (ZZ - 270), table_headers[hdr_set[i]])
    }

    // --- Table rows ---------------------------------------------------------

    report.SetFont(_HELVETICA_FONT, _EMPTY_STRING, (11 / PT))

    report.SetTextColor(0, 0, 0)                  // <== _BLACK_COLOR (#000000)

    var y float64 = 0

    // Printing table rows.
//  for i := uint(0); i <           num_rows; i++ {
    for i := uint(0); i < MAX_ROWS_IN_A_PAGE; i++ {
        if ((i & 1) == 1) {
            report.SetFillColor(221, 221, 221) // <== _RAINY_DAY_COLOR(#dddddd)
            report.Rect(17, ((ZZ - 6) - (260 - y)), 176, 6, _RECT_STYLE_FILL)
        }

        for j := uint(0); j < num_hdrs; j++ {
                   if (j == 1) {
                x =  17
            } else if (j == 2) {
                x =  40
            } else if (j == 3) {
                x =  78
            } else if (j == 4) {
                x = 123
            } else if (j == 5) {
                x = 148
            } else { // <== Includes (j == 0).
                x =   0
            }

            report.Text((20 + x), (ZZ - (262 - y)), row_set[i][j])
        }

        y += 6
    }

    // --- Footer bar ---------------------------------------------------------

    report.SetFillColor(170, 170, 170) // <== _VERY_LIGHT_COBALT_COLOR(#aaaaaa)

    report.Rect(17, ((ZZ - 6) - 20), 176, 6, _RECT_STYLE_FILL)

    // --- Footer txt ---------------------------------------------------------

    report.SetFont(_TIMES_FONT, _FONT_STYLE_BOLD, (12 / PT))

    report.SetTextColor(238, 238, 238)    // <== _YET_NOT_WHITE_COLOR (#eeeeee)

    report.Text(20, (ZZ - 22), strconv.Itoa(int(num_rows))+_ROWS_IN_SET_FOOTER+
        _ROWS_SHOWN_FOOTER_1 + strconv.Itoa(int(MAX_ROWS_IN_A_PAGE)) +
        _ROWS_SHOWN_FOOTER_2)

    // ------------------------------------------------------------------------

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

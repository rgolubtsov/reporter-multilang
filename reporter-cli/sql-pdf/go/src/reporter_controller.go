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
import "strings"
import "strconv"

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

/** The controller class of the application. */
type ReporterController struct {
    /*
     * Attached methods:
     *   - pdf_report_generate(cnx      *sql.DB,
     *                         mysql     bool,
     *                         postgres  bool,
     *                         exec      string) int
     *
     *   - _page_body_draw(report       string,
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
 * @param mysql    The indicator that shows whether the database connection
 *                 object is MySQL connection.
 *                 (Default is False)
 * @param postgres The indicator that shows whether the database connection
 *                 object is PostgreSQL connection.
 *                 (Default is False)
 * @param exec     The executable path.
 *
 * @return The exit code indicating the status of generating the PDF report.
 */
func (ReporterController) pdf_report_generate(cnx      *sql.DB,
                                              mysql     bool,
                                              postgres  bool,
                                              exec      string) int {

    var ret int = _EXIT_SUCCESS

    var class___ ReporterController
    var __name__ string = reflect.TypeOf(class___).Name()

    __file__ := exec

    // Instantiating the model class.
    model := new(ReporterModel)

    // Retrieving a list of all data items stored in the database.
    hdr_set, row_set := model.get_all_data_items(cnx)

    // Retrieving a list of data items for a given date period.
//  hdr_set, row_set := model.get_data_items_by_date(FROM, TO, cnx)

    // ------------------------------------------------------------------------
    // --- Debug output - Begin -----------------------------------------------
    // ------------------------------------------------------------------------
    pdf_report_path := class___._get_pdf_report_path(__file__)

    fmt.Printf(_S_FMT,     __name__ + _COLON_SPACE_SEP + pdf_report_path +
               _SPACE    + _V_BAR           + _SPACE                     +
               "hdr_set" + _COLON_SPACE_SEP + strconv.Itoa(len(hdr_set)) +
               _SPACE    + _V_BAR           + _SPACE                     +
               "row_set" + _COLON_SPACE_SEP + strconv.Itoa(len(row_set)) +
               _NEW_LINE)
    // ------------------------------------------------------------------------
    // --- Debug output - End -------------------------------------------------
    // ------------------------------------------------------------------------

    return ret
}

/* Draws the PDF report page body (data). */
func (ReporterController) _page_body_draw(report       string,
                                          hdr_set  [  ]string,
                                          row_set  [][]string,
                                          num_hdrs     uint,
                                          num_rows     uint) int {

    var ret int = _EXIT_SUCCESS

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

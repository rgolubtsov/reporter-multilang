/*
 * reporter-cli/sql-pdf/go/src/controller_helper.go
 * ============================================================================
 * Reporter Multilang. Version 0.5.9
 * ============================================================================
 * A tool to generate human-readable reports based on data from various sources
 * with the focus on its implementation using a series of programming languages
 * ============================================================================
 * Written by Radislav (Radicchio) Golubtsov, 2016-2025
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

// Helper constants.
const _EXIT_FAILURE    int    =    1 //    Failing exit status.
const _EXIT_SUCCESS    int    =    0 // Successful exit status.
const _EMPTY_STRING    string =   ""
const _NEW_LINE        string = "\n"
const _S_FMT           string = "%s"
const _COLON_SPACE_SEP string = ": "
const _COLON           string =  ":"
const _SLASH           string =  "/"
const _AT              string =  "@"
const _QM              string =  "?"
const _SQ              string =  "'"
const _V_BAR           string =  "|"
const _SPACE           string =  " "
const _SEP_NOD         string =  "+"
const _SEP_COG         string =  "-"
const _CURRENT_DIR     string = "./"

// Common error messages.
const _ERROR_PREFIX        string = "Error"
const _ERROR_NO_DB_CONNECT string = "Could not connect to the database."
const _ERROR_NO_DATA       string = "No data found."
const _ERROR_NO_REPORT_GEN string = "Could not generate the report."

/** The helper for the controller class and related ones. */
type ControllerHelper struct {
    /*
     * In Vala/Genie this helper class contains commonly used constants
     * and nothing more. But Go doesn't allow constants to be declared
     * inside a class. Hence, the presence of this class is completely
     * useless in the context of the given app, but let it exist anyway,
     * in a "reserved" state.
     */
}

/**
 * This class is a simplified Go implementation of well-known
 * and very attractive Text::TabularDisplay Perl module by Darren Chamberlain:
 * http://search.cpan.org/~darren/Text-TabularDisplay-1.38/TabularDisplay.pm .
 *
 * The output is identical to that generated by the MySQL/MariaDB CLI client
 * when doing something like 'select ... from ... where ...;' query
 * on a database table.
 *
 * See comments in respective methods for their proper usage.
 */
type TabularDisplay struct {
    /** The table headers (headings). */
    hdr_set [  ]string

    /** The table rows (table body data). */
    row_set [][]string

    /**
     * The finally consolidated tabular data,
     * which has to be printed to the client.
     */
    tableau string

    /*
     * Attached methods:
     *   - render(_hdr_set []string, _row_set [][]string) string
     *   - _separator_draw(num_hdrs      uint,
     *                     hdr_set_len []uint,
     *                     col_max_len []uint) string
     */
}

/**
 * Populates class data members with the given table data.
 * Then renders those data into string representation,
 * which is ready to be printed to the client.
 *
 * @param _hdr_set The table headers (headings).
 *                 (Simple array of strings.)
 * @param _row_set The table rows (table body data).
 *                 (2D-array of strings.)
 *
 * @return The string representation of collected tabular data.
 */
func (TabularDisplay) render(_hdr_set []string, _row_set [][]string) string {
    var c TabularDisplay

    c.tableau = _EMPTY_STRING

    if ((_hdr_set != nil) && (_row_set != nil)) {
        num_hdrs := uint(len(_hdr_set))
        num_rows := uint(len(_row_set))

        c.hdr_set = make([  ]string, num_hdrs)
        c.row_set = make([][]string, num_rows)

        for i := uint(0); i < num_rows; i++ {
            c.row_set[i] = make([]string, num_hdrs)
        }

        c.hdr_set = _hdr_set
        c.row_set = _row_set
// ----------------------------------------------------------------------------
        var hdr_set_len [  ]uint = make([  ]uint, num_hdrs)
        var row_set_len [][]uint = make([][]uint, num_rows)

        for i := uint(0); i < num_rows; i++ {
            row_set_len[i] = make([]uint, num_hdrs)
        }

        var col_max_len [  ]uint = make([  ]uint, num_rows)
// ----------------------------------------------------------------------------
        // Searching for the max data length in each column
        // to form its width.
        for j := uint(0); j < num_hdrs; j++ {
            hdr_set_len[j] = uint(len(c.hdr_set[j]))

            for i := uint(0); i < num_rows; i++ {
                row_set_len[i][j] = uint(len(c.row_set[i][j]))
            }

            // Assuming this is the max.
            col_max_len[j] = row_set_len[0][j]

            // Searching for the max element in a column.
            for i := uint(0); i < num_rows; i++ {
                if (row_set_len[i][j] > col_max_len[j]) {
                    col_max_len[j] = row_set_len[i][j]
                }
            }
        }
// ----------------------------------------------------------------------------
        c.tableau += c._separator_draw(num_hdrs, hdr_set_len, col_max_len)
// ----------------------------------------------------------------------------
        // Printing table headers.
        for i := uint(0); i < num_hdrs; i++ {
//          fmt.Printf(_S_FMT, _V_BAR + _SPACE + c.hdr_set[i])
            c.tableau    +=    _V_BAR + _SPACE + c.hdr_set[i]

            var spacers uint = 0

            if (hdr_set_len[i] < col_max_len[i]) {
                spacers = col_max_len[i] - hdr_set_len[i]
            }

            spacers++; // <== Additional spacer (padding).

            for m := uint(0); m < spacers; m++ {
//              fmt.Printf(_S_FMT, _SPACE)
                c.tableau    +=    _SPACE
            }
        }

//      fmt.Printf(_S_FMT, _V_BAR + _NEW_LINE)
        c.tableau    +=    _V_BAR + _NEW_LINE
// ----------------------------------------------------------------------------
        c.tableau += c._separator_draw(num_hdrs, hdr_set_len, col_max_len)
// ----------------------------------------------------------------------------
        // Printing table rows.
        for i := uint(0); i < num_rows; i++ {
            for j := uint(0); j < num_hdrs; j++ {
//              fmt.Printf(_S_FMT, _V_BAR + _SPACE + c.row_set[i][j])
                c.tableau    +=    _V_BAR + _SPACE + c.row_set[i][j]

                if (col_max_len[j] < hdr_set_len[j]) {
                    col_max_len[j] = hdr_set_len[j]
                }

                var spacers uint = 0

                if (row_set_len[i][j] < col_max_len[j]) {
                    spacers = col_max_len[j] - row_set_len[i][j]
                }

                spacers++; // <== Additional spacer (padding).

                for m := uint(0); m < spacers; m++ {
//                  fmt.Printf(_S_FMT, _SPACE)
                    c.tableau    +=    _SPACE
                }
            }

//          fmt.Printf(_S_FMT, _V_BAR + _NEW_LINE)
            c.tableau    +=    _V_BAR + _NEW_LINE
        }
// ----------------------------------------------------------------------------
        c.tableau += c._separator_draw(num_hdrs, hdr_set_len, col_max_len)
// ----------------------------------------------------------------------------
    } else {
        c.hdr_set = [  ]string{  }
        c.row_set = [][]string{{}}
    }

    return c.tableau
}

/* Helper method. Draws a horizontal separator for a table. */
func (TabularDisplay) _separator_draw(num_hdrs      uint,
                                      hdr_set_len []uint,
                                      col_max_len []uint) string {

    var c TabularDisplay

    for i := uint(0); i < num_hdrs; i++ {
//      fmt.Printf(_S_FMT, _SEP_NOD)
        c.tableau    +=    _SEP_NOD

        var sep_len uint = hdr_set_len[i]

        if (sep_len < col_max_len[i]) {
            sep_len = col_max_len[i]
        }

        sep_len += 2; // <== Two additional separator cogs (padding).

        for m := uint(0); m < sep_len; m++ {
//          fmt.Printf(_S_FMT, _SEP_COG)
            c.tableau    +=    _SEP_COG
        }
    }

//  fmt.Printf(_S_FMT, _SEP_NOD + _NEW_LINE)
    c.tableau    +=    _SEP_NOD + _NEW_LINE

    return c.tableau
}

// vim:set nu et ts=4 sw=4:

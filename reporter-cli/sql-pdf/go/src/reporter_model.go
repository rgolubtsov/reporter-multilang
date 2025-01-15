/*
 * reporter-cli/sql-pdf/go/src/reporter_model.go
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

import "database/sql"
import "reflect"
import "fmt"
import "strings"

/*
 * This TZ pattern is used to get rid of it when retrieving date-records
 * taken from PostgreSQL and SQLite databases; MySQL records are already
 * free of it.
 */
const _TZ_PATTERN string = "T00:00:00Z"

/** The model class of the application. */
type ReporterModel struct {
    /*
     * Attached methods:
     *   - get_all_data_items(cnx *sql.DB) ([]string, [][]string)
     *   - get_data_items_by_date(from      string,
     *                            to        string,
     *                            cnx      *sql.DB,
     *                            postgres  bool) ([]string, [][]string)
     */
}

/**
 * Retrieves a list of all data items stored in the database.
 *
 * @param cnx The database connection object.
 *
 * @return Two arrays containing table headers and rows.
 */
func (ReporterModel) get_all_data_items(cnx *sql.DB) ([]string, [][]string) {
    var hdr_set [  ]string
    var row_set [][]string

    var class___ ReporterModel
    var __name__ string = reflect.TypeOf(class___).Name()

    var e error

    sql_select := "select"               +
        "      x0.name as arch,"         +
        "      x1.name as repo,"         +
        "   items.name,"                 +
        " attr_x2      as version,"      +
//      "   items.description,"          +
        " attr_x3      as last_updated," +
        " attr_x4      as flag_date"     +
    " from"                              +
        " data_items items,"             +
        "   attr_x0s x0,"                +
        "   attr_x1s x1"                 +
    " where"                             +
        " (attr_x0_id  = x0.id) and"     +
        " (attr_x1_id  = x1.id)"/*and"*/ +
//      " (attr_x4 is not null)"         +
    " order by"                          +
        " items.name,"                   +
        "       arch"

    var stmt *sql.Stmt

    // Preparing the SQL statement.
    stmt, e = cnx.Prepare(sql_select)

    if (e != nil) {
        fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + _ERROR_PREFIX +
                                      _COLON_SPACE_SEP + e.Error() + _NEW_LINE)
    }; if (stmt == nil) {
        hdr_set = []string{}; row_set = [][]string{{}}; return hdr_set, row_set
    }

    defer stmt.Close()

    var res_set *sql.Rows

    // Executing the SQL statement.
    res_set, e = stmt.Query()

    if (e != nil) {
        fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + _ERROR_PREFIX +
                                      _COLON_SPACE_SEP + e.Error() + _NEW_LINE)
    }; if (res_set == nil) {
        hdr_set = []string{}; row_set = [][]string{{}}; return hdr_set, row_set
    }

    defer res_set.Close()

    // Retrieving the result set metadata -- table headers.
    hdr_set, e = res_set.Columns()

    if (e != nil) {
        fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + _ERROR_PREFIX +
                                      _COLON_SPACE_SEP + e.Error() + _NEW_LINE)
    }; if (hdr_set == nil) {
        hdr_set = []string{}; row_set = [][]string{{}}; return hdr_set, row_set
    }

    num_rows := uint(0); for (res_set.Next()) { num_rows++ }
    num_hdrs := uint(len(hdr_set))

    if (num_rows == 0) {
        hdr_set = []string{}; row_set = [][]string{{}}; return hdr_set, row_set
    }

    // Executing the SQL statement once again.
    res_set, e = stmt.Query()

    if (e != nil) {
        fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + _ERROR_PREFIX +
                                      _COLON_SPACE_SEP + e.Error() + _NEW_LINE)
    }; if (res_set == nil) {
        hdr_set = []string{}; row_set = [][]string{{}}; return hdr_set, row_set
    }

    defer res_set.Close()

    var row_ary []sql.NullString

    // Allocating the row_set array before populating it.
    row_set = make([][]string, num_rows)

    // Retrieving and processing the result set -- table rows.
    var i uint = 0; for (res_set.Next()) {
        row_ary = make([]sql.NullString, num_hdrs)

        e = res_set.Scan(&row_ary[0], // arch
                         &row_ary[1], // repo
                         &row_ary[2], // name
                         &row_ary[3], // version
                         &row_ary[4], // last_updated
                         &row_ary[5]) // flag_date

        if (e != nil) {
            fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP+_ERROR_PREFIX +
                                          _COLON_SPACE_SEP+e.Error()+_NEW_LINE)

            hdr_set=[]string{}; row_set=[][]string{{}}; return hdr_set, row_set
        }

        row_set[i] = make([]string, num_hdrs)

        for j := uint(0); j < num_hdrs; j++ {
            if (row_ary[j].Valid) {
                row_set[i][j] = row_ary[j].String
            } else {
                row_set[i][j] = _EMPTY_STRING
            }

            if ((j == 4) || (j == 5)) {
                row_set[i][j] = strings.TrimSuffix(row_set[i][j], _TZ_PATTERN)
            }
        }

        i++
    }

    return hdr_set, row_set
}

/**
 * Retrieves a list of data items for a given date period.
 *
 * @param from     The start date to retrieve data set.
 * @param to       The end   date to retrieve data set.
 * @param cnx      The database connection object.
 * @param postgres The indicator that shows whether the database connection
 *                 object is PostgreSQL connection.
 *
 * @return Two arrays containing table headers and rows.
 */
func (ReporterModel) get_data_items_by_date(from      string,
                                            to        string,
                                            cnx      *sql.DB,
                                            postgres  bool) ([  ]string,
                                                             [][]string) {

    var hdr_set [  ]string
    var row_set [][]string

    var class___ ReporterModel
    var __name__ string = reflect.TypeOf(class___).Name()

    var e error

    sql_select := "select"               +
        "      x0.name as arch,"         +
        "      x1.name as repo,"         +
        "   items.name,"                 +
        " attr_x2      as version,"      +
//      "   items.description,"          +
        " attr_x3      as last_updated," +
        " attr_x4      as flag_date"     +
    " from"                              +
        " data_items items,"             +
        "   attr_x0s x0,"                +
        "   attr_x1s x1"                 +
    " where"                             +
        " (attr_x0_id = x0.id) and"      +
        " (attr_x1_id = x1.id) and"
// ----------------------------------------------------------------------------
// Note: PostgreSQL driver (lib/pq) can handle only dollar-sign-prefixed
//       positional placeholders ($n), whilst MySQL driver(go-sql-driver/mysql)
//       can handle only question-mark-placeholders (?). And SQLite driver
//       (mattn/go-sqlite3)can do both. So that the use of dollar-sign-prefixed
//       placeholders is mandatory only for PostgreSQL ops.
// ----------------------------------------------------------------------------
    if (postgres) {   sql_select +=
//      " (attr_x3    >=   $1) and"      +
//      " (attr_x3    <=   $2)"
// ----------------------------------------------------------------------------
        " (attr_x3 between $1 and $2)"
// ----------------------------------------------------------------------------
    } else {          sql_select +=
//      " (attr_x3    >=    ?) and"      +
//      " (attr_x3    <=    ?)"
// ----------------------------------------------------------------------------
        " (attr_x3 between  ? and  ?)"
// ----------------------------------------------------------------------------
    };                sql_select +=
    " order by"                          +
        " items.name,"                   +
        "       arch"

    var stmt *sql.Stmt

    // Preparing the SQL statement.
    stmt, e = cnx.Prepare(sql_select)

    if (e != nil) {
        fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + _ERROR_PREFIX +
                                      _COLON_SPACE_SEP + e.Error() + _NEW_LINE)
    }; if (stmt == nil) {
        hdr_set = []string{}; row_set = [][]string{{}}; return hdr_set, row_set
    }

    defer stmt.Close()

    var res_set *sql.Rows

    // Executing the SQL statement.
    res_set, e = stmt.Query(from, to)

    if (e != nil) {
        fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + _ERROR_PREFIX +
                                      _COLON_SPACE_SEP + e.Error() + _NEW_LINE)
    }; if (res_set == nil) {
        hdr_set = []string{}; row_set = [][]string{{}}; return hdr_set, row_set
    }

    defer res_set.Close()

    // Retrieving the result set metadata -- table headers.
    hdr_set, e = res_set.Columns()

    if (e != nil) {
        fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + _ERROR_PREFIX +
                                      _COLON_SPACE_SEP + e.Error() + _NEW_LINE)
    }; if (hdr_set == nil) {
        hdr_set = []string{}; row_set = [][]string{{}}; return hdr_set, row_set
    }

    num_rows := uint(0); for (res_set.Next()) { num_rows++ }
    num_hdrs := uint(len(hdr_set))

    if (num_rows == 0) {
        hdr_set = []string{}; row_set = [][]string{{}}; return hdr_set, row_set
    }

    // Executing the SQL statement once again.
    res_set, e = stmt.Query(from, to)

    if (e != nil) {
        fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + _ERROR_PREFIX +
                                      _COLON_SPACE_SEP + e.Error() + _NEW_LINE)
    }; if (res_set == nil) {
        hdr_set = []string{}; row_set = [][]string{{}}; return hdr_set, row_set
    }

    defer res_set.Close()

    var row_ary []sql.NullString

    // Allocating the row_set array before populating it.
    row_set = make([][]string, num_rows)

    // Retrieving and processing the result set -- table rows.
    var i uint = 0; for (res_set.Next()) {
        row_ary = make([]sql.NullString, num_hdrs)

        e = res_set.Scan(&row_ary[0], // arch
                         &row_ary[1], // repo
                         &row_ary[2], // name
                         &row_ary[3], // version
                         &row_ary[4], // last_updated
                         &row_ary[5]) // flag_date

        if (e != nil) {
            fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP+_ERROR_PREFIX +
                                          _COLON_SPACE_SEP+e.Error()+_NEW_LINE)

            hdr_set=[]string{}; row_set=[][]string{{}}; return hdr_set, row_set
        }

        row_set[i] = make([]string, num_hdrs)

        for j := uint(0); j < num_hdrs; j++ {
            if (row_ary[j].Valid) {
                row_set[i][j] = row_ary[j].String
            } else {
                row_set[i][j] = _EMPTY_STRING
            }

            if ((j == 4) || (j == 5)) {
                row_set[i][j] = strings.TrimSuffix(row_set[i][j], _TZ_PATTERN)
            }
        }

        i++
    }

    return hdr_set, row_set
}

// vim:set nu et ts=4 sw=4:

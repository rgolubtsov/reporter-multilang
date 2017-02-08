/*
 * reporter-cli/sql-pdf/go/src/reporter_model.go
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

/** The model class of the application. */
type ReporterModel struct {
    /*
     * Attached methods:
     *   - get_all_data_items(cnx *sql.DB) ([]string, [][]string)
     *   - get_data_items_by_date(from  string,
     *                            to    string,
     *                            cnx  *sql.DB) ([]string, [][]string)
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

    // TODO: Implement getting a list of data items.

    return hdr_set, row_set
}

/**
 * Retrieves a list of data items for a given date period.
 *
 * @param from The start date to retrieve data set.
 * @param to   The end   date to retrieve data set.
 * @param cnx  The database connection object.
 *
 * @return Two arrays containing table headers and rows.
 */
func (ReporterModel) get_data_items_by_date(from  string,
                                            to    string,
                                            cnx  *sql.DB) ([  ]string,
                                                           [][]string) {

    var hdr_set [  ]string
    var row_set [][]string

    // TODO: Implement getting a list of data items.

    return hdr_set, row_set
}

// vim:set nu:et:ts=4:sw=4:

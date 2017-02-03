/*
 * reporter-cli/sql-pdf/go/src/reporter_primary.go
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

import "os"

/**
 * Constant: The database server name.
 *     TODO: Move to cli args.
 */
const HOSTNAME string = "10.0.2.100"
//const HOSTNAME string = "localhost"

/**
 * Constant: The username to connect to the database.
 *     TODO: Move to cli args.
 */
const USERNAME string = "reporter"

/**
 * Constant: The password to connect to the database.
 *     TODO: Move to cli args.
 */
const PASSWORD string = "retroper12345678"

/**
 * Constant: The database name.
 *     TODO: Move to cli args.
 */
const DATABASE string = "reporter_multilang"

/**
 * Constant: The data source name (DSN) prefix for PostgreSQL database --
 *           the logical database identifier prefix.
 *     TODO: Move to the startup() method.
 */
const PG_DSN_PREFIX string = "postgres"

/**
 * Constant: The SQLite database location.
 *     TODO: Move to cli args.
 */
const SQLITE_DB_DIR string = "lib/data"

/** The main class of the application. */
type ReporterPrimary struct {
    /*
     * Attached methods:
     *   - startup(args []string) int
     *   - _get_sqlite_db_path(exec string) string
     */
}

/**
 * Starts up the app.
 *
 * @param args The array of command-line arguments.
 *
 * @return The exit code indicating the app overall execution status.
 */
func (ReporterPrimary) startup(args []string) int {
    var ret int = _EXIT_SUCCESS

    if (args[0] == _EMPTY_STRING) {
        ret = _EXIT_FAILURE
    }

    // TODO: Implement all the rest...

    return ret
}

/*
 * Helper method.
 * Returns the SQLite database path,
 * relative to the executable's location.
 */
func (ReporterPrimary) _get_sqlite_db_path(exec string) string {
    // TODO: Split the executable's location path into separate dirs.
    exec_path := exec

    // TODO: Calculate and construct the SQLite DB path from separate dirs.
    sqlite_db_path := exec_path

    return sqlite_db_path
}

// The application entry point.
func main(/*args []string*/) {
    var args_len uint = uint(len(os.Args) - 1)

    var args [1]string

    // Checking for cli args presence.
    if (args_len > 0) {
        args[0] = os.Args[1]
    } else {
        args[0] = _EMPTY_STRING
    }

    // Instantiating the main class.
    reporter := new(ReporterPrimary)

    // Starting up the app.
    var ret int = reporter.startup(args[:])

    os.Exit(ret)
}

// vim:set nu:et:ts=4:sw=4:

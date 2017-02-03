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
import "reflect"
import "fmt"
import "strconv"

// Database switches. They indicate which database to connect to.
const _MY_CONNECT string = "mysql"
const _PG_CONNECT string = "postgres"
const _SL_CONNECT string = "sqlite"

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

    var class___ ReporterPrimary
    var __name__ string = reflect.TypeOf(class___).Name()

    __file__  := args[0]
    db_switch := args[1]

    var mycnx bool = false // <== Suppose the database is not MySQL.
    var pgcnx bool = false // <== Suppose the database is not PostgreSQL.
    var slcnx bool = false // <== Suppose the database is not SQLite.

    // Trying to connect to the database.
           if (db_switch == _MY_CONNECT) {
        // TODO: Implement connecting to MySQL database.

        mycnx = true
    } else if (db_switch == _PG_CONNECT) {
        // TODO: Implement connecting to PostgreSQL database.

        pgcnx = true
    } else if (db_switch == _SL_CONNECT) {
        // TODO: Implement connecting to SQLite database.

        slcnx = true
    } else {
        ret = _EXIT_FAILURE

        fmt.Printf(_S_FMT, __name__ +
                   _COLON_SPACE_SEP + _ERROR_PREFIX        +
                   _COLON_SPACE_SEP + _ERROR_NO_DB_CONNECT +
                   _EMPTY_STRING    + _NEW_LINE)

//      return ret
    }

    // TODO: Implement all the rest...

    // ------------------------------------------------------------------------
    // --- Debug output - Begin -----------------------------------------------
    // ------------------------------------------------------------------------
    fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP          + __file__ +
               _COLON_SPACE_SEP + db_switch                 +
               _COLON_SPACE_SEP + strconv.FormatBool(mycnx) +
               _COLON_SPACE_SEP + strconv.FormatBool(pgcnx) +
               _COLON_SPACE_SEP + strconv.FormatBool(slcnx) +
               _COLON_SPACE_SEP + strconv.Itoa(ret)         + _NEW_LINE)
    // ------------------------------------------------------------------------
    // --- Debug output - End -------------------------------------------------
    // ------------------------------------------------------------------------

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

    var args [2]string

    args[0] = os.Args[0]
    args[1] = _EMPTY_STRING

    // Checking for cli args presence.
    if (args_len > 0) {
        args[1] = os.Args[1]
    }

    // Instantiating the main class.
    reporter := new(ReporterPrimary)

    // Starting up the app.
    var ret int = reporter.startup(args[:])

    os.Exit(ret)
}

// vim:set nu:et:ts=4:sw=4:

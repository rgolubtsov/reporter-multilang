/*
 * reporter-cli/sql-pdf/go/src/reporter_primary.go
 * ============================================================================
 * Reporter Multilang. Version 0.1
 * ============================================================================
 * A tool to generate human-readable reports based on data from various sources
 * with the focus on its implementation using a series of programming languages
 * ============================================================================
 * Written by Radislav (Radicchio) Golubtsov, 2016-2020
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
import "database/sql"
import _ "github.com/go-sql-driver/mysql"
import _ "github.com/lib/pq"
import _ "github.com/mattn/go-sqlite3"
import "strings"
import "fmt"

/* Database switches. They indicate which database to connect to. */
const _MY_CONNECT string = "mysql"
const _PG_CONNECT string = "postgres"
const _SL_CONNECT string = "sqlite"

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
 * Constant: The database server name.
 *     TODO: Move to cli args.
 */
const HOSTNAME string = "10.0.2.100"
//const HOSTNAME string = "localhost"

/**
 * Constant: The database name.
 *     TODO: Move to cli args.
 */
const DATABASE string = "reporter_multilang"

/* The MySQL DSN connection port number. */
const _MY_PORT string = "3306"

/**
 * Constant: The data source name (DSN) for MySQL database --
 *           the logical database identifier.
 *     TODO: Move to the startup() method.
 */
const MY_DSN string = USERNAME + _COLON +
                      PASSWORD + _AT    + "tcp("   +
                      HOSTNAME + _COLON + _MY_PORT + ")" + _SLASH +
                      DATABASE

/* The PostgreSQL DSN connection options (params). */
const _PG_OPTS string = "sslmode=disable"

/**
 * Constant: The data source name (DSN) for PostgreSQL database --
 *           the logical database identifier.
 *     TODO: Move to the startup() method.
 */
const PG_DSN string = _PG_CONNECT + _COLON + _SLASH + _SLASH + USERNAME +
                                                      _COLON + PASSWORD +
                                                      _AT    + HOSTNAME +
                                                      _SLASH + DATABASE +
                                                      _QM    + _PG_OPTS

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
    var e   error

    var class___ ReporterPrimary
    var __name__ string = reflect.TypeOf(class___).Name()

    __file__  := args[0]
    db_switch := args[1]

    var cnx   *sql.DB = nil
    var pgcnx  bool   = false // <== Suppose the database is not PostgreSQL.

    // Connecting to the database.
           if (db_switch == _MY_CONNECT) {
        cnx, e =   sql.Open(_MY_CONNECT, MY_DSN)
    } else if (db_switch == _PG_CONNECT) {
        cnx, e =   sql.Open(_PG_CONNECT, PG_DSN)

        pgcnx  = true
    } else if (db_switch == _SL_CONNECT) {
        cnx, e =   sql.Open(_SL_CONNECT + "3",
                                class___._get_sqlite_db_path(__file__))
    }

    if (cnx != nil) {
        // Disconnecting from the database (later).
        defer cnx.Close()
    }

    if (e != nil) {
        ret = _EXIT_FAILURE

        fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + _ERROR_PREFIX +
                                      _COLON_SPACE_SEP + e.Error() + _NEW_LINE)

        return ret
    }

    if (cnx != nil) {
        // Checking the database connection.
        e = cnx.Ping()

        if (e != nil) {
            ret = _EXIT_FAILURE

            fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP+_ERROR_PREFIX +
                                          _COLON_SPACE_SEP+e.Error()+_NEW_LINE)

            return ret
        }

        // Instantiating the controller class.
        ctrl := new(ReporterController)

        // Generating the PDF report.
        ret = ctrl.pdf_report_generate(cnx, pgcnx, __file__)
    } else {
        ret = _EXIT_FAILURE

        fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + _ERROR_PREFIX +
                                      _COLON_SPACE_SEP + _ERROR_NO_DB_CONNECT +
                                                         _NEW_LINE)

        return ret
    }

    return ret
}

/*
 * Helper method.
 * Returns the SQLite database path,
 * relative to the executable's location.
 */
func (ReporterPrimary) _get_sqlite_db_path(exec string) string {
    exec_path := strings.Split(exec, _SLASH)

    var exec_path_len uint = uint(len(exec_path))

//  for i := uint(0); i < exec_path_len; i++ {
//      fmt.Printf(_S_FMT, exec_path[i] + _NEW_LINE)
//  }

    exec_path_new := make([]string, exec_path_len - 1)
    copy(exec_path_new, exec_path)
    exec_path_new[exec_path_len - 2] = SQLITE_DB_DIR

//  for i := uint(0); i < (exec_path_len - 1); i++ {
//      fmt.Printf(_S_FMT, exec_path_new[i] + _NEW_LINE)
//  }

    sqlite_db_path := strings.Join(exec_path_new, _SLASH) + _SLASH + DATABASE

    return sqlite_db_path
}

/*
 * The application entry point.
 *
 * It looks for the presence of the first and the only cmd-line argument.
 * This should be one of the following:
 *   - mysql    -- if the database used is MySQL/MariaDB.
 *   - postgres -- if the database used is PostgreSQL.
 *   - sqlite   -- if the database used is SQLite.
 *
 * Currently these three RDBMSs are only supported.
 *
 * Any other cmd-line args are ignored; if the first cmd-line arg is not valid
 * or there are no any passed args at all, the application will issue
 * the following error and exit:
 *
 *   <main-app-class-name>: Error: Could not connect to the database.
 *
 * Thus, to use e.g. PostgreSQL database as the data source, run the app
 * in the following way:
 *
 *   $ ./reporter-cli/sql-pdf/go/bin/reporter-sql-pdf postgres
 */
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

// vim:set nu et ts=4 sw=4:

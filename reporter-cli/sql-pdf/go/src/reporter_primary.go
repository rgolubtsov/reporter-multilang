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
import "database/sql"
import _ "github.com/go-sql-driver/mysql"
import _ "github.com/lib/pq"
import _ "github.com/mattn/go-sqlite3"
import "strings"
import "fmt"
import "strconv"

// Database switches. They indicate which database to connect to.
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

// The MySQL DSN connection port number.
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

// The PostgreSQL DSN connection options (params).
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
    var mycnx  bool   = false // <== Suppose the database is not MySQL.
    var pgcnx  bool   = false // <== Suppose the database is not PostgreSQL.
    var slcnx  bool   = false // <== Suppose the database is not SQLite.

    sqlite_db_path := _EMPTY_STRING

    // Connecting to the database.
           if (db_switch == _MY_CONNECT) {
        cnx, e = sql.Open(_MY_CONNECT, MY_DSN)

        mycnx = true
    } else if (db_switch == _PG_CONNECT) {
        cnx, e = sql.Open(_PG_CONNECT, PG_DSN)

        pgcnx = true
    } else if (db_switch == _SL_CONNECT) {
        sqlite_db_path = class___._get_sqlite_db_path(__file__)

        cnx, e = sql.Open(_SL_CONNECT + "3", sqlite_db_path)

        slcnx = true
    }

    // Disconnecting from the database (later).
    defer cnx.Close()

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

        // TODO: Implement generating the PDF report.

               if (mycnx) {
            fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + MY_DSN +
                                          _NEW_LINE)
        } else if (pgcnx) {
            fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + PG_DSN +
                                          _NEW_LINE)
        } else if (slcnx) {
            fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + sqlite_db_path +
                                          _NEW_LINE)
        }

        // Disconnecting from the database.
//      cnx.Close()
    } else {
        ret = _EXIT_FAILURE

        fmt.Printf(_S_FMT, __name__ + _COLON_SPACE_SEP + _ERROR_PREFIX +
                                      _COLON_SPACE_SEP + _ERROR_NO_DB_CONNECT +
                                                         _NEW_LINE)

        return ret
    }

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

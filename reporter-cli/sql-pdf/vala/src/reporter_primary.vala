/*
 * reporter-cli/sql-pdf/vala/src/reporter_primary.vala
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

   #if (MYSQL)
    using Mysql;
 #elif (POSTGRES)
    using Postgres;
 #elif (SQLITE)
    using Sqlite;
#endif

namespace CliSqlPdf {
/** The main class of the application. */
class ReporterPrimary {
    /**
     * Constant: The database server name.
     *     TODO: Move to cli args.
     */
    const string HOSTNAME = "10.0.2.100";
//  const string HOSTNAME = "localhost";

    /**
     * Constant: The username to connect to the database.
     *     TODO: Move to cli args.
     */
    const string USERNAME = "reporter";

    /**
     * Constant: The password to connect to the database.
     *     TODO: Move to cli args.
     */
    const string PASSWORD = "retroper12345678";

    /**
     * Constant: The database name.
     *     TODO: Move to cli args.
     */
    const string DATABASE = "reporter_multilang";

    /**
     * Constant: The data source name (DSN) prefix for PostgreSQL database --
     *           the logical database identifier prefix.
     *     TODO: Move to the startup() method.
     */
    const string PG_DSN_PREFIX = "postgres";

    /**
     * Constant: The SQLite database location.
     *     TODO: Move to cli args.
     */
    const string SQLITE_DB_DIR = "lib/data";

    /**
     * Starts up the app.
     *
     * @param args The array of command-line arguments.
     *
     * @return The exit code indicating the app overall execution status.
     */
    public int startup(string[] args) {
        int ret = Posix.EXIT_SUCCESS;

        string __name__ = typeof(ReporterPrimary).name();

        // Instantiating the controller helper class.
        var aux = new ControllerHelper();

        var __file__ = args[0];

        Database dbcnx;

        var __cnx = aux.EMPTY_STRING;

        // Instantiating the controller class.
        var ctrl = new ReporterController();

        // Trying to connect to the database.
        try {
   #if (MYSQL)
            dbcnx = new Database();

            // Connecting to MySQL database.
            var cnx = dbcnx.real_connect(HOSTNAME,
                                         USERNAME,
                                         PASSWORD,
                                         DATABASE);

            if (cnx) {
                __cnx
= aux.NEW_LINE + "     Host info" + aux.COLON_SPACE_SEP + dbcnx.get_host_info()
+ aux.NEW_LINE + "   Server info" + aux.COLON_SPACE_SEP + dbcnx.get_server_info()
+ aux.NEW_LINE + "Server version" + aux.COLON_SPACE_SEP + dbcnx.get_server_version()
                                                               .to_string();

                // Generating the PDF report.
                ret = ctrl.pdf_report_generate(dbcnx, __file__);
            } else {
                ret = Posix.EXIT_FAILURE;

                stdout.printf(aux.S_FMT, __name__
                            + aux.COLON_SPACE_SEP + aux.ERROR_PREFIX
                            + aux.COLON_SPACE_SEP + aux.ERROR_NO_DB_CONNECT
                            + dbcnx.error()       + aux.NEW_LINE);

                return ret;
            }
 #elif (POSTGRES)
            // Connecting to PostgreSQL database.
//          dbcnx = set_db_login(HOSTNAME, aux.EMPTY_STRING, // port
//                                         aux.EMPTY_STRING, // options
//                                         aux.EMPTY_STRING, // gtty
//                               DATABASE,
//                               USERNAME,
//                               PASSWORD);

            var pg_dsn = PG_DSN_PREFIX + aux.COLON + aux.SLASH
                                       + aux.SLASH + USERNAME
                                       + aux.COLON + PASSWORD
                                       + aux.AT    + HOSTNAME
                                       + aux.SLASH + DATABASE;

            // Connecting to PostgreSQL database (preferred method).
            dbcnx = connect_db(pg_dsn);

            if (dbcnx != null) {
                if (dbcnx.get_status() == ConnectionStatus.OK) {
                    __cnx
= aux.NEW_LINE + "     Host info" + aux.COLON_SPACE_SEP + dbcnx.get_host()
                                  + aux.COLON           + dbcnx.get_port()
+ aux.NEW_LINE + "   Server info" + aux.COLON_SPACE_SEP + dbcnx.get_protocol_Version()
                                                               .to_string()
+ aux.NEW_LINE + "Server version" + aux.COLON_SPACE_SEP + dbcnx.get_server_version()
                                                               .to_string();

                    // Generating the PDF report.
                    ret = ctrl.pdf_report_generate(dbcnx, __file__);
                } else {
                    ret = Posix.EXIT_FAILURE;

                    stdout.printf(aux.S_FMT, __name__
                              + aux.COLON_SPACE_SEP + aux.ERROR_PREFIX
                              + aux.COLON_SPACE_SEP + aux.ERROR_NO_DB_CONNECT
                              + dbcnx.get_error_message() + aux.NEW_LINE);

                    return ret;
                }
            }
 #elif (SQLITE)
            var sqlite_db_path = _get_sqlite_db_path(__file__, aux);

            // Connecting to SQLite database.
            var cnx = Database.open_v2(sqlite_db_path, out(dbcnx),
                                                   OPEN_READONLY);

            if ((cnx == OK) && (dbcnx != null)) {
                __cnx
= aux.NEW_LINE + " Database path" + aux.COLON_SPACE_SEP + sqlite_db_path
+ aux.NEW_LINE + "Engine ver str" + aux.COLON_SPACE_SEP + libversion()
+ aux.NEW_LINE + "Engine version" + aux.COLON_SPACE_SEP + libversion_number()
                                                         .to_string();

                // Generating the PDF report.
                ret = ctrl.pdf_report_generate(dbcnx, __file__);
            } else {
                ret = Posix.EXIT_FAILURE;

                stdout.printf(aux.S_FMT, __name__
                            + aux.COLON_SPACE_SEP + aux.ERROR_PREFIX
                            + aux.COLON_SPACE_SEP + aux.ERROR_NO_DB_CONNECT
                            + dbcnx.errmsg()      + aux.NEW_LINE);

                return ret;
            }
#endif
            // ----------------------------------------------------------------
            // --- Debug output - Begin ---------------------------------------
            // ----------------------------------------------------------------
//          stdout.printf(aux.S_FMT, __name__
//                      + aux.COLON_SPACE_SEP + __cnx + aux.NEW_LINE);
            // ----------------------------------------------------------------
            // --- Debug output - End -----------------------------------------
            // ----------------------------------------------------------------
        } catch (Error e) {
            ret = Posix.EXIT_FAILURE;

            stdout.printf(aux.S_FMT, __name__
                        + aux.COLON_SPACE_SEP + aux.ERROR_PREFIX
                        + aux.COLON_SPACE_SEP + e.message + aux.NEW_LINE);

            return ret;
        }

        return ret;
    }

    /*
     * Helper method.
     * Returns the SQLite database path, relative to the executable's location.
     */
    string _get_sqlite_db_path(string exec, ControllerHelper aux) {
        var exec_path = exec.split(aux.SLASH);

//      for (uint i = 0; i < exec_path.length; i++) {
//          stdout.printf(aux.S_FMT, exec_path[i] + aux.NEW_LINE);
//      }

        exec_path.resize(exec_path.length - 1);
        exec_path       [exec_path.length - 1] = SQLITE_DB_DIR;

//      for (uint i = 0; i < exec_path.length; i++) {
//          stdout.printf(aux.S_FMT, exec_path[i] + aux.NEW_LINE);
//      }

        var sqlite_db_path = string.joinv(aux.SLASH, exec_path)
                                        + aux.SLASH + DATABASE;

        return sqlite_db_path;
    }

    /** Default constructor. */
    public ReporterPrimary() {}
}
} // namespace CliSqlPdf

// The application entry point.
public static int main(string[] args) {
    // Instantiating the main class.
    var reporter = new CliSqlPdf.ReporterPrimary();

    // Starting up the app.
    int ret = reporter.startup(args);

    return ret;
}

// vim:set nu:et:ts=4:sw=4:

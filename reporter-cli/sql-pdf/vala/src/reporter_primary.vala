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
    // Database switches. They indicate which database to connect to.
    public const string _MY_CONNECT = "mysql";
    public const string _PG_CONNECT = "postgres";
    public const string _SL_CONNECT = "sqlite";

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
    const string PG_DSN_PREFIX = _PG_CONNECT;

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

        var db_switch = args[0];
        var __file__  = args[1];

        Database dbcnx;

        var __cnx = aux._EMPTY_STRING;

        // Instantiating the controller class.
        var ctrl = new ReporterController();

        // Trying to connect to the database.
        try {
   #if (MYSQL)
            if (db_switch == _MY_CONNECT) {
                dbcnx = new Database();

                // Connecting to MySQL database.
                var cnx = dbcnx.real_connect(HOSTNAME,
                                             USERNAME,
                                             PASSWORD,
                                             DATABASE);

                if (cnx) {
                    __cnx
= aux._NEW_LINE + "     Host info" + aux._COLON_SPACE_SEP + dbcnx.get_host_info()
+ aux._NEW_LINE + "   Server info" + aux._COLON_SPACE_SEP + dbcnx.get_server_info()
+ aux._NEW_LINE + "Server version" + aux._COLON_SPACE_SEP + dbcnx.get_server_version()
                                                                 .to_string();

                    // Generating the PDF report.
                    ret = ctrl.pdf_report_generate(dbcnx);
                } else {
                    ret = Posix.EXIT_FAILURE;

                    stdout.printf(aux._S_FMT, __name__
                              + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                              + aux._COLON_SPACE_SEP + aux._ERROR_NO_DB_CONNECT
                              + dbcnx.error()        + aux._NEW_LINE);

                    return ret;
                }
            }
 #elif (POSTGRES)
            if (db_switch == _PG_CONNECT) {
                // Connecting to PostgreSQL database.
//              dbcnx = set_db_login(HOSTNAME, aux._EMPTY_STRING, // port
//                                             aux._EMPTY_STRING, // options
//                                             aux._EMPTY_STRING, // gtty
//                                   DATABASE,
//                                   USERNAME,
//                                   PASSWORD);

                var pg_dsn = PG_DSN_PREFIX + aux._COLON + aux._SLASH
                                           + aux._SLASH + USERNAME
                                           + aux._COLON + PASSWORD
                                           + aux._AT    + HOSTNAME
                                           + aux._SLASH + DATABASE;

                // Connecting to PostgreSQL database (preferred method).
                dbcnx = connect_db(pg_dsn);

                if (dbcnx != null) {
                    if (dbcnx.get_status() == ConnectionStatus.OK) {

                        __cnx
= aux._NEW_LINE + "     Host info" + aux._COLON_SPACE_SEP + dbcnx.get_host()
                                   + aux._COLON           + dbcnx.get_port()
+ aux._NEW_LINE + "   Server info" + aux._COLON_SPACE_SEP + dbcnx.get_protocol_Version()
                                                                 .to_string()
+ aux._NEW_LINE + "Server version" + aux._COLON_SPACE_SEP + dbcnx.get_server_version()
                                                                 .to_string();

                        // Generating the PDF report.
                        ret = ctrl.pdf_report_generate(dbcnx);
                    } else {
                        ret = Posix.EXIT_FAILURE;

                        stdout.printf(aux._S_FMT, __name__
                              + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                              + aux._COLON_SPACE_SEP + aux._ERROR_NO_DB_CONNECT
                              + dbcnx.get_error_message() + aux._NEW_LINE);

                        return ret;
                    }
                }
            }
 #elif (SQLITE)
            if (db_switch == _SL_CONNECT) {
                var sqlite_db_path = _get_sqlite_db_path(__file__, aux);

                // Connecting to SQLite database.
                var cnx = Database.open(sqlite_db_path, out(dbcnx));

                if (cnx == OK) {
                    __cnx
= aux._NEW_LINE + " Database path" + aux._COLON_SPACE_SEP + sqlite_db_path
+ aux._NEW_LINE + "Engine ver str" + aux._COLON_SPACE_SEP + libversion()
+ aux._NEW_LINE + "Engine version" + aux._COLON_SPACE_SEP + libversion_number()
                                                           .to_string();

                    // Generating the PDF report.
                    ret = ctrl.pdf_report_generate(dbcnx);
                } else {
                    ret = Posix.EXIT_FAILURE;

                    stdout.printf(aux._S_FMT, __name__
                              + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                              + aux._COLON_SPACE_SEP + aux._ERROR_NO_DB_CONNECT
                              + dbcnx.errmsg()       + aux._NEW_LINE);

                    return ret;
                }
            }
#endif
            // ----------------------------------------------------------------
            // --- Debug output - Begin ---------------------------------------
            // ----------------------------------------------------------------
            stdout.printf(aux._S_FMT, __name__
                        + aux._COLON_SPACE_SEP + __cnx + aux._NEW_LINE);
            // ----------------------------------------------------------------
            // --- Debug output - End -----------------------------------------
            // ----------------------------------------------------------------
        } catch (Error e) {
            ret = Posix.EXIT_FAILURE;

            stdout.printf(aux._S_FMT, __name__
                        + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                        + aux._COLON_SPACE_SEP + e.message + aux._NEW_LINE);

            return ret;
        }

        return ret;
    }

    /*
     * Helper method.
     * Returns the SQLite database path, relative to the executable's location.
     */
    string _get_sqlite_db_path(string exec, ControllerHelper aux) {
        var exec_path = exec.split(aux._SLASH);

//      for (uint i = 0; i < exec_path.length; i++) {
//          stdout.printf(aux._S_FMT, exec_path[i] + aux._NEW_LINE);
//      }

        exec_path.resize(exec_path.length - 1);
        exec_path       [exec_path.length - 1] = SQLITE_DB_DIR;

//      for (uint i = 0; i < exec_path.length; i++) {
//          stdout.printf(aux._S_FMT, exec_path[i] + aux._NEW_LINE);
//      }

        var sqlite_db_path = string.joinv(aux._SLASH, exec_path)
                                        + aux._SLASH + DATABASE;

        return sqlite_db_path;
    }

    /** Default constructor. */
    public ReporterPrimary() {}
}

} // namespace CliSqlPdf

// The application entry point.
public static int main(string[] args) {
    string[] argz = {};

    // Instantiating the main class.
    var reporter = new CliSqlPdf.ReporterPrimary();

   #if (MYSQL)
    argz[0] = reporter._MY_CONNECT;
 #elif (POSTGRES)
    argz[0] = reporter._PG_CONNECT;
 #elif (SQLITE)
    argz[0] = reporter._SL_CONNECT;
#endif

    argz[1] = args[0];

    // Starting up the app.
    int ret = reporter.startup(argz);

    return ret;
}

// vim:set nu:et:ts=4:sw=4:

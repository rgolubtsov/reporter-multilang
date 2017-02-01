[indent=4]
/* reporter-cli/sql-pdf/genie/src/reporter_primary.gs
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

#if   (MYSQL)
uses   Mysql
#elif (POSTGRES)
uses   Postgres
#elif (SQLITE)
uses   Sqlite
#endif

namespace CliSqlPdf
    /** The main class of the application. */
    class ReporterPrimary
        /**
         * Constant: The database server name.
         *     TODO: Move to cli args.
         */
        const HOSTNAME: string = "10.0.2.100"
//      const HOSTNAME: string = "localhost"

        /**
         * Constant: The username to connect to the database.
         *     TODO: Move to cli args.
         */
        const USERNAME: string = "reporter"

        /**
         * Constant: The password to connect to the database.
         *     TODO: Move to cli args.
         */
        const PASSWORD: string = "retroper12345678"

        /**
         * Constant: The database name.
         *     TODO: Move to cli args.
         */
        const DATABASE: string = "reporter_multilang"

        /**
         * Constant: The data source name (DSN) prefix for PostgreSQL database
         *           -- the logical database identifier prefix.
         *     TODO: Move to the startup() method.
         */
        const PG_DSN_PREFIX: string = "postgres"

        /**
         * Constant: The SQLite database location.
         *     TODO: Move to cli args.
         */
        const SQLITE_DB_DIR: string = "lib/data"

        /**
         * Starts up the app.
         *
         * @param args The array of command-line arguments.
         *
         * @return The exit code indicating the app overall execution status.
         */
        def startup(args: array of string[]): int
            ret: int = Posix.EXIT_SUCCESS

            __name__: string = typeof(ReporterPrimary).name()

            // Instantiating the controller helper class.
            var aux = new ControllerHelper()

            var __file__ = args[0]

            dbcnx: Database

            var __cnx = aux._EMPTY_STRING

            // Instantiating the controller class.
            var ctrl = new ReporterController()

            // Trying to connect to the database.
            try
#if   (MYSQL)
                dbcnx = new Database()

                // Connecting to MySQL database.
                var cnx = dbcnx.real_connect(HOSTNAME,
                                             USERNAME,
                                             PASSWORD,
                                             DATABASE)

                if (cnx)
                    __cnx = (
  aux._NEW_LINE + "     Host info" + aux._COLON_SPACE_SEP + dbcnx
                                        .get_host_info()
+ aux._NEW_LINE + "   Server info" + aux._COLON_SPACE_SEP + dbcnx
                                        .get_server_info()
+ aux._NEW_LINE + "Server version" + aux._COLON_SPACE_SEP + dbcnx
                                        .get_server_version().to_string())

                    // Generating the PDF report.
                    ret = ctrl.pdf_report_generate(dbcnx, __file__)
                else
                    ret = Posix.EXIT_FAILURE

                    stdout.printf(aux._S_FMT, __name__
                              + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                              + aux._COLON_SPACE_SEP + aux._ERROR_NO_DB_CONNECT
                              + dbcnx.error()        + aux._NEW_LINE)

                    return ret
#elif (POSTGRES)
                // Connecting to PostgreSQL database.
//              dbcnx = set_db_login(HOSTNAME, aux._EMPTY_STRING, // port
//                                             aux._EMPTY_STRING, // options
//                                             aux._EMPTY_STRING, // gtty
//                                   DATABASE,
//                                   USERNAME,
//                                   PASSWORD)

                var pg_dsn = (PG_DSN_PREFIX + aux._COLON + aux._SLASH
                                            + aux._SLASH + USERNAME
                                            + aux._COLON + PASSWORD
                                            + aux._AT    + HOSTNAME
                                            + aux._SLASH + DATABASE)

                // Connecting to PostgreSQL database (preferred method).
                dbcnx = connect_db(pg_dsn)

                if (dbcnx != null)
                    if (dbcnx.get_status() == ConnectionStatus.OK)
                        __cnx = (
  aux._NEW_LINE + "     Host info" + aux._COLON_SPACE_SEP + dbcnx.get_host()
                                   + aux._COLON           + dbcnx.get_port()
+ aux._NEW_LINE + "   Server info" + aux._COLON_SPACE_SEP + dbcnx
                                        .get_protocol_Version().to_string()
+ aux._NEW_LINE + "Server version" + aux._COLON_SPACE_SEP + dbcnx
                                        .get_server_version().to_string())

                        // Generating the PDF report.
                        ret = ctrl.pdf_report_generate(dbcnx, __file__)
                    else
                        ret = Posix.EXIT_FAILURE

                        stdout.printf(aux._S_FMT, __name__
                              + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                              + aux._COLON_SPACE_SEP + aux._ERROR_NO_DB_CONNECT
                              + dbcnx.get_error_message() + aux._NEW_LINE)

                        return ret
#elif (SQLITE)
                var sqlite_db_path = _get_sqlite_db_path(__file__, aux)

                // Connecting to SQLite database.
                var cnx = Database.open_v2(sqlite_db_path, out(dbcnx),
                                                       OPEN_READONLY)

                if ((cnx == OK) && (dbcnx != null))
                    __cnx = (
  aux._NEW_LINE + " Database path" + aux._COLON_SPACE_SEP + sqlite_db_path
+ aux._NEW_LINE + "Engine ver str" + aux._COLON_SPACE_SEP + libversion()
+ aux._NEW_LINE + "Engine version" + aux._COLON_SPACE_SEP + libversion_number()
                                                           .to_string())

                    // Generating the PDF report.
                    ret = ctrl.pdf_report_generate(dbcnx, __file__)
                else
                    ret = Posix.EXIT_FAILURE

                    stdout.printf(aux._S_FMT, __name__
                              + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                              + aux._COLON_SPACE_SEP + aux._ERROR_NO_DB_CONNECT
                              + dbcnx.errmsg()       + aux._NEW_LINE)

                    return ret
#endif
                // ------------------------------------------------------------
                // --- Debug output - Begin -----------------------------------
                // ------------------------------------------------------------
//              stdout.printf(aux._S_FMT, __name__
//                          + aux._COLON_SPACE_SEP + __cnx + aux._NEW_LINE)
                // ------------------------------------------------------------
                // --- Debug output - End -------------------------------------
                // ------------------------------------------------------------

            except e: Error
                ret = Posix.EXIT_FAILURE

                stdout.printf(aux._S_FMT, __name__
                            + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                            + aux._COLON_SPACE_SEP + e.message + aux._NEW_LINE)

                return ret

            return ret

        /*
         * Helper method.
         * Returns the SQLite database path,
         * relative to the executable's location.
         */
        def _get_sqlite_db_path(exec: string, aux: ControllerHelper): string
            var exec_path = exec.split(aux._SLASH)

//          for i: uint = 0 to (exec_path.length - 1)
//              stdout.printf(aux._S_FMT, exec_path[i] + aux._NEW_LINE)

            exec_path.resize(exec_path.length - 1)
            exec_path       [exec_path.length - 1] = SQLITE_DB_DIR

//          for i: uint = 0 to (exec_path.length - 1)
//              stdout.printf(aux._S_FMT, exec_path[i] + aux._NEW_LINE)

            var sqlite_db_path = (string.joinv(aux._SLASH, exec_path)
                                             + aux._SLASH + DATABASE)

            return sqlite_db_path

        /** Default constructor. */
        construct()
            pass

// The application entry point.
init//(string[] args)
    // Instantiating the main class.
    var reporter = new CliSqlPdf.ReporterPrimary()

    // Starting up the app.
    ret: int = reporter.startup(args)

    Posix.exit(ret)

// vim:set nu:et:ts=4:sw=4:

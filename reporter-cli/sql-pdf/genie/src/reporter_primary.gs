[indent=4]
/* reporter-cli/sql-pdf/genie/src/reporter_primary.gs
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

            cnx: Database = null

            // Connecting to the database.
#if   (MYSQL)
            cnx = new Database()

            var cnx_ok = cnx.real_connect(HOSTNAME,
                                          USERNAME,
                                          PASSWORD,
                                          DATABASE)

            if (cnx != null)
                if (cnx_ok)
#elif (POSTGRES)
            var pg_dsn = (PG_DSN_PREFIX + aux._COLON + aux._SLASH
                                        + aux._SLASH + USERNAME
                                        + aux._COLON + PASSWORD
                                        + aux._AT    + HOSTNAME
                                        + aux._SLASH + DATABASE)

            cnx = connect_db(pg_dsn)

            if (cnx != null)
                if (cnx.get_status() == ConnectionStatus.OK)
#elif (SQLITE)
            var sqlite_db_path = _get_sqlite_db_path(__file__, aux)

            var cnx_ok = Database.open_v2(sqlite_db_path, out(cnx),
                                                    OPEN_READONLY)

            if (cnx != null)
                if (cnx_ok == OK)
#endif
                    // Instantiating the controller class.
                    var ctrl = new ReporterController()

                    // Generating the PDF report.
                    ret = ctrl.pdf_report_generate(cnx, __file__)
                else
                    ret = Posix.EXIT_FAILURE

                    var error_msg = (aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                            + aux._COLON_SPACE_SEP + aux._ERROR_NO_DB_CONNECT)
#if   (MYSQL)
                    error_msg += cnx.error()
#elif (POSTGRES)
                    error_msg += cnx.get_error_message()
#elif (SQLITE)
                    error_msg += cnx.errmsg()
#endif
                    stdout.printf(aux._S_FMT,__name__+error_msg+aux._NEW_LINE)

                    return ret
            else
                ret = Posix.EXIT_FAILURE

                stdout.printf(aux._S_FMT, __name__
                            + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                            + aux._COLON_SPACE_SEP + aux._ERROR_NO_DB_CONNECT
                                                   + aux._NEW_LINE)

                return ret

            return ret

#if   (SQLITE)
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
#endif

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

// vim:set nu et ts=4 sw=4:

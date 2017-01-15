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

using Mysql;

namespace CliSqlPdf {

/** The main class of the application. */
class ReporterPrimary {
    // Database switches. They indicate which database to connect to.
    public const string _MY_CONNECT = "mysql";
    public const string _PG_CONNECT = "postgres";
    public const string _SL_CONNECT = "sqlite";

    /**
     * Constant: The database name.
     *     TODO: Move to cli args.
     */
    const string DATABASE = "reporter_multilang";

    /**
     * Constant: The database server name.
     *     TODO: Move to cli args.
     */
    const string HOSTNAME = "10.0.2.100";
    //const string HOSTNAME = "localhost";

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
     * Constant: The SQLite database location.
     *     TODO: Move to cli args.
     */
    const string SQLITE_DB_DIR = "data";

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

        var aux = new ControllerHelper();

        var db_switch = args[0];

        Database mycnx;

        var __cnx = aux._EMPTY_STRING + aux._SLASH;

        // Trying to connect to the database.
        try {
                   if (db_switch == _MY_CONNECT) {
                mycnx = new Database();

                var cnx = mycnx.real_connect(HOSTNAME,
                                             USERNAME,
                                             PASSWORD,
                                             DATABASE);

                if (cnx) {
        __cnx = "Host info" + aux._COLON_SPACE_SEP + mycnx.get_host_info()
         + " | Server info" + aux._COLON_SPACE_SEP + mycnx.get_server_info()
      + " | Server version" + aux._COLON_SPACE_SEP + mycnx.get_server_version()
                                                          .to_string();
                } else {
                    ret = Posix.EXIT_FAILURE;

                    stdout.printf("%s%s%s%s%s%s%s", __name__,
                              aux._COLON_SPACE_SEP, aux._ERROR_PREFIX,
                              aux._COLON_SPACE_SEP, aux._ERROR_NO_DB_CONNECT,
                                     mycnx.error(), aux._NEW_LINE);

                    return ret;
                }
            } else if (db_switch == _PG_CONNECT) {
                // TODO: Implement connecting to PostgreSQL database.
            } else if (db_switch == _SL_CONNECT) {
                // TODO: Implement connecting to SQLite database.
            }
        } catch (Error e) {
            ret = Posix.EXIT_FAILURE;

            stdout.printf("%s%s%s%s%s%s", __name__, aux._COLON_SPACE_SEP,
                                 aux._ERROR_PREFIX, aux._COLON_SPACE_SEP,
                                         e.message, aux._NEW_LINE);

            return ret;
        }

        // --------------------------------------------------------------------
        // --- Debug output - Begin -------------------------------------------
        // --------------------------------------------------------------------
        stdout.printf("%s%s%s%s", __name__, aux._COLON_SPACE_SEP, __cnx,
                                            aux._NEW_LINE);
        // --------------------------------------------------------------------
        // --- Debug output - End ---------------------------------------------
        // --------------------------------------------------------------------

        return ret;
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

    // Starting up the app.
    int ret = reporter.startup(argz);

    return ret;
}

// vim:set nu:et:ts=4:sw=4:

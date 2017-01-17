/*
 * reporter-cli/sql-pdf/vala/src/reporter_model.vala
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

/** The model class of the application. */
class ReporterModel {
    /**
     * Retrieves a list of all data items stored in the database.
     *
     * @param dbcnx   The database handle object.
     * @param hdr_set The result set metadata (table headers).
     *                (Output param.)
     *
     * @return The result set (table rows).
     */
    public string[] get_all_data_items(Database dbcnx, out string[] hdr_set) {
        string[] row_set = {};
                 hdr_set = {};

        // TODO: Implement preparing the SQL statement.
        // TODO: Implement retrieving the result set metadata
        //              -- table headers.
        // TODO: Implement retrieving and processing the result set
        //              -- table rows.

        return row_set;
    }

    /**
     * Retrieves a list of data items for a given date period.
     *
     * @param from    The start date to retrieve data set.
     * @param to      The end   date to retrieve data set.
     * @param dbcnx   The database handle object.
     * @param hdr_set The result set metadata (table headers).
     *                (Output param.)
     *
     * @return The result set (table rows).
     */
    public string[] get_data_items_by_date(    string   from,
                                               string   to,
                                               Database dbcnx,
                                           out string[] hdr_set) {

        string[] row_set = {};
                 hdr_set = {};

        // TODO: Implement preparing the SQL statement.
        // TODO: Implement retrieving the result set metadata
        //              -- table headers.
        // TODO: Implement retrieving and processing the result set
        //              -- table rows.

        return row_set;
    }

    /** Default constructor. */
    public ReporterModel() {}
}

} // namespace CliSqlPdf

// vim:set nu:et:ts=4:sw=4:

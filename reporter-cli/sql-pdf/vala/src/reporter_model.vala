/*
 * reporter-cli/sql-pdf/vala/src/reporter_model.vala
 * ============================================================================
 * Reporter Multilang. Version 0.5.9
 * ============================================================================
 * A tool to generate human-readable reports based on data from various sources
 * with the focus on its implementation using a series of programming languages
 * ============================================================================
 * Written by Radislav (Radicchio) Golubtsov, 2016-2023
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
    public string[,] get_all_data_items(Database dbcnx, out string[] hdr_set) {
        string[,] row_set = {{},{}};
                  hdr_set = {     };

        // Instantiating the controller helper class.
        var aux = new ControllerHelper();

        var sql_select = "select"
            + "      x0.name as arch,"
            + "      x1.name as repo,"
            + "   items.name,"
            + " attr_x2      as version,"
//          + "   items.description,"
            + " attr_x3      as last_updated,"
            + " attr_x4      as flag_date"
        + " from"
            + " data_items items,"
            + "   attr_x0s x0,"
            + "   attr_x1s x1"
        + " where"
            + " (attr_x0_id  = x0.id) and"
            + " (attr_x1_id  = x1.id)" // and"
//          + " (attr_x4 is not null)"
        + " order by"
            + " items.name,"
            + "       arch";

   #if (MYSQL)
        // Executing the SQL statement.
        var ret = dbcnx.real_query(sql_select, sql_select.length);

        if (ret != 0) {
            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        /*
         * Retrieving the result set object,
         * containing both table headers and rows.
         */
        Result res_set = dbcnx.store_result();

        if ((res_set == null) || (dbcnx.errno() != 0)) {
            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        var num_rows = res_set.num_rows();
        var num_hdrs = res_set.num_fields();
 #elif (POSTGRES)
        // Preparing the SQL statement.
        Result res_set = dbcnx.prepare(aux.EMPTY_STRING, sql_select, null);

        if ((res_set == null)
            || (res_set.get_status() != ExecStatus.COMMAND_OK)) {

            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        // Executing the SQL statement.
        res_set = dbcnx.exec_prepared(aux.EMPTY_STRING, 0, null, null, null,
                                                        0);

        if ((res_set == null)
            || (res_set.get_status() != ExecStatus.TUPLES_OK)) {

            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        var num_rows = res_set.get_n_tuples();
        var num_hdrs = res_set.get_n_fields();
 #elif (SQLITE)
        Statement stmt;

        // Preparing the SQL statement.
        var ret = dbcnx.prepare_v2(sql_select, sql_select.length, out(stmt));

        if ((ret != OK) || (stmt == null)) {
            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        // FIXME: Ugly but workable... but ugly. -----------------------------+
        //                                                                    |
        var num_rows = 0; while (stmt.step() == ROW) { num_rows++; } // <-----+
        var num_hdrs = stmt.column_count();
#endif

        if (num_rows == 0) {
            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        // Allocating the hdr_set array before populating it.
        hdr_set.resize((int) num_hdrs);

        // Retrieving and processing the result set metadata -- table headers.
        for (uint i = 0; i < num_hdrs; i++) {
   #if (MYSQL)
            hdr_set[i] = res_set.fetch_field().name;
 #elif (POSTGRES)
            hdr_set[i] = res_set.get_field_name((int) i);
 #elif (SQLITE)
            hdr_set[i] = stmt.column_name((int) i);
#endif
        }

        /*
         * Note: Since the error "The name `resize' does not exist
         *       in the context of `string[,]?'", it needs to allocate 2D-array
         *       using a constructor:
         */
        row_set = new string[num_rows,num_hdrs];

        // Retrieving and processing the result set -- table rows.
   #if (!SQLITE)
        for (uint i = 0; i < num_rows; i++) {
 #else
        uint i = 0; while (stmt.step() == ROW) {
#endif

   #if (MYSQL)
            var row_ary = res_set.fetch_row();
#endif

            for (uint j = 0; j < num_hdrs; j++) {
   #if (MYSQL)
                row_set[i,j] = row_ary[j];
 #elif (POSTGRES)
                row_set[i,j] = res_set.get_value((int) i, (int) j);
 #elif (SQLITE)
                row_set[i,j] = stmt.column_text((int) j);
#endif

   #if (!POSTGRES)
                if (row_set[i,j] == null) {
                    row_set[i,j] = aux.EMPTY_STRING;
                }
#endif
            }

   #if (SQLITE)
            i++;
#endif
        }

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
    public string[,] get_data_items_by_date(    string   from,
                                                string   to,
                                                Database dbcnx,
                                            out string[] hdr_set) {

        string[,] row_set = {{},{}};
                  hdr_set = {     };

        // Instantiating the controller helper class.
        var aux = new ControllerHelper();

        var sql_select = "select"
            + "      x0.name as arch,"
            + "      x1.name as repo,"
            + "   items.name,"
            + " attr_x2      as version,"
//          + "   items.description,"
            + " attr_x3      as last_updated,"
            + " attr_x4      as flag_date"
        + " from"
            + " data_items items,"
            + "   attr_x0s x0,"
            + "   attr_x1s x1"
        + " where"
            + " (attr_x0_id = x0.id) and"
            + " (attr_x1_id = x1.id) and"
// ----------------------------------------------------------------------------
// Note: PostgreSQL client lib (libpq) can handle only dollar-sign-prefixed
//       positional placeholders ($n), whilst MySQL client lib (mysql)
//       can handle question-mark-placeholders enclosed into single quotation
//       marks ('?'). And SQLite client lib (sqlite3) can handle question-mark-
//       placeholders too, but without any extra stuff around them (?).
//       Thus, for both MySQL and SQLite libs it is possible to use a unified
//       notation, but for SQLite ops it needs to make some preprocessing
//       of the query string -- see below.
// ----------------------------------------------------------------------------
   #if (POSTGRES)
//          + " (attr_x3   >=    $1) and"
//          + " (attr_x3   <=    $2)"
// ----------------------------------------------------------------------------
            + " (attr_x3 between  $1 and  $2)"
// ----------------------------------------------------------------------------
 #else
//          + " (attr_x3   >=   '?') and"
//          + " (attr_x3   <=   '?')"
// ----------------------------------------------------------------------------
            + " (attr_x3 between '?' and '?')"
// ----------------------------------------------------------------------------
#endif
        + " order by"
            + " items.name,"
            + "       arch";

   #if (MYSQL)
        // Binding values to SQL placeholders.
        sql_select = sql_select.replace(aux.QM, aux.S_FMT).printf(from, to);

        // Executing the SQL statement.
        var ret = dbcnx.real_query(sql_select, sql_select.length);

        if (ret != 0) {
            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        /*
         * Retrieving the result set object,
         * containing both table headers and rows.
         */
        Result res_set = dbcnx.store_result();

        if ((res_set == null) || (dbcnx.errno() != 0)) {
            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        var num_rows = res_set.num_rows();
        var num_hdrs = res_set.num_fields();
 #elif (POSTGRES)
        // Preparing the SQL statement.
        Result res_set = dbcnx.prepare(aux.EMPTY_STRING, sql_select, null);

        if ((res_set == null)
            || (res_set.get_status() != ExecStatus.COMMAND_OK)) {

            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        // Executing the SQL statement.
        res_set = dbcnx.exec_prepared(aux.EMPTY_STRING, 2, {from, to}, null,
                                                  null, 0);

        if ((res_set == null)
            || (res_set.get_status() != ExecStatus.TUPLES_OK)) {

            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        var num_rows = res_set.get_n_tuples();
        var num_hdrs = res_set.get_n_fields();
 #elif (SQLITE)
        // Removing single quotation marks from SQL placehldrs (preprocessing).
        sql_select = sql_select.replace(aux.SQ, aux.EMPTY_STRING);

        Statement stmt;

        // Preparing the SQL statement.
        var ret = dbcnx.prepare_v2(sql_select, sql_select.length, out(stmt));

        if ((ret != OK) || (stmt == null)) {
            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        // Binding values to SQL placeholders.
        stmt.bind_text(1, from);
        stmt.bind_text(2,   to);

        // FIXME: Ugly but workable... but ugly. -----------------------------+
        //                                                                    |
        var num_rows = 0; while (stmt.step() == ROW) { num_rows++; } // <-----+
        var num_hdrs = stmt.column_count();
#endif

        if (num_rows == 0) {
            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        // Allocating the hdr_set array before populating it.
        hdr_set.resize((int) num_hdrs);

        // Retrieving and processing the result set metadata -- table headers.
        for (uint i = 0; i < num_hdrs; i++) {
   #if (MYSQL)
            hdr_set[i] = res_set.fetch_field().name;
 #elif (POSTGRES)
            hdr_set[i] = res_set.get_field_name((int) i);
 #elif (SQLITE)
            hdr_set[i] = stmt.column_name((int) i);
#endif
        }

        // Allocating the row_set array before populating it.
        row_set = new string[num_rows,num_hdrs];

        // Retrieving and processing the result set -- table rows.
   #if (!SQLITE)
        for (uint i = 0; i < num_rows; i++) {
 #else
        uint i = 0; while (stmt.step() == ROW) {
#endif

   #if (MYSQL)
            var row_ary = res_set.fetch_row();
#endif

            for (uint j = 0; j < num_hdrs; j++) {
   #if (MYSQL)
                row_set[i,j] = row_ary[j];
 #elif (POSTGRES)
                row_set[i,j] = res_set.get_value((int) i, (int) j);
 #elif (SQLITE)
                row_set[i,j] = stmt.column_text((int) j);
#endif

   #if (!POSTGRES)
                if (row_set[i,j] == null) {
                    row_set[i,j] = aux.EMPTY_STRING;
                }
#endif
            }

   #if (SQLITE)
            i++;
#endif
        }

        return row_set;
    }

    /** Default constructor. */
    public ReporterModel() {}
}
} // namespace CliSqlPdf

// vim:set nu et ts=4 sw=4:

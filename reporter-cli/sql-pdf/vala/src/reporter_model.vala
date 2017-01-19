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
    public string[,] get_all_data_items(Database dbcnx, out string[] hdr_set) {
        string[,] row_set = {{},{}};
                  hdr_set = {     };

        string __name__ = typeof(ReporterModel).name();

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

        if (res_set == null) {
            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        var num_rows = res_set.num_rows();
        var num_hdrs = res_set.num_fields();

        if (num_rows == 0) {
            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        // Allocating the hdr_set array before populating it.
        hdr_set.resize((int) num_hdrs);

        // Retrieving and processing the result set metadata -- table headers.
        for (uint i = 0; i < num_hdrs; i++) {
            hdr_set[i] = res_set.fetch_field().name;
        }

        /*
         * Note: Since the error "The name `resize' does not exist
         *       in the context of `string[,]?'", it needs to allocate 2D-array
         *       using a constructor:
         */
        row_set = new string[num_rows,num_hdrs];

        // Retrieving and processing the result set -- table rows.
        for (uint i = 0; i < num_rows; i++) {
            var row_ary = res_set.fetch_row();

            for (uint j = 0; j < num_hdrs; j++) {
                row_set[i,j] = row_ary[j];

                if (row_set[i,j] == null) {
                    row_set[i,j] = aux._EMPTY_STRING;
                }
            }
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

        string __name__ = typeof(ReporterModel).name();

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
            + " (attr_x3   >=   '?') and"
            + " (attr_x3   <=   '?')"
// ----------------------------------------------------------------------------
//          + " (attr_x3 between '?' and '?')"
// ----------------------------------------------------------------------------
        + " order by"
            + " items.name,"
            + "       arch";

        // Binding values to SQL placeholders.
        sql_select = sql_select.replace(aux._QM, aux._S_FMT).printf(from, to);

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

        if (res_set == null) {
            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        var num_rows = res_set.num_rows();
        var num_hdrs = res_set.num_fields();

        if (num_rows == 0) {
            row_set = {{},{}}; hdr_set = {}; return row_set;
        }

        // Allocating the hdr_set array before populating it.
        hdr_set.resize((int) num_hdrs);

        // Retrieving and processing the result set metadata -- table headers.
        for (uint i = 0; i < num_hdrs; i++) {
            hdr_set[i] = res_set.fetch_field().name;
        }

        // Allocating the row_set array before populating it.
        row_set = new string[num_rows,num_hdrs];

        // Retrieving and processing the result set -- table rows.
        for (uint i = 0; i < num_rows; i++) {
            var row_ary = res_set.fetch_row();

            for (uint j = 0; j < num_hdrs; j++) {
                row_set[i,j] = row_ary[j];

                if (row_set[i,j] == null) {
                    row_set[i,j] = aux._EMPTY_STRING;
                }
            }
        }

        return row_set;
    }

    /** Default constructor. */
    public ReporterModel() {}
}

} // namespace CliSqlPdf

// vim:set nu:et:ts=4:sw=4:

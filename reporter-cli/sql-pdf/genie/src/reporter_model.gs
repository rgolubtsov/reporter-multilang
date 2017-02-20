[indent=4]
/* reporter-cli/sql-pdf/genie/src/reporter_model.gs
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
    /** The model class of the application. */
    class ReporterModel
        /**
         * Retrieves a list of all data items stored in the database.
         *
         * @param dbcnx   The database handle object.
         * @param hdr_set The result set metadata (table headers).
         *                (Output param.)
         *
         * @return The result set (table rows).
         */
        def get_all_data_items(dbcnx  : Database,
                           out hdr_set: array of string[]): array of string[,]

            var row_set = new array of string[0,0]
                hdr_set = new array of string[ 0 ]

            // Instantiating the controller helper class.
            var aux = new ControllerHelper()

            var sql_select = ("select"
                + "      x0.name as arch,"
                + "      x1.name as repo,"
                + "   items.name,"
                + " attr_x2      as version,"
//              + "   items.description,"
                + " attr_x3      as last_updated,"
                + " attr_x4      as flag_date"
            + " from"
                + " data_items items,"
                + "   attr_x0s x0,"
                + "   attr_x1s x1"
            + " where"
                + " (attr_x0_id  = x0.id) and"
                + " (attr_x1_id  = x1.id)" // and"
//              + " (attr_x4 is not null)"
            + " order by"
                + " items.name,"
                + "       arch")

#if   (MYSQL)
            // Executing the SQL statement.
            var ret = dbcnx.real_query(sql_select, sql_select.length)

            if (ret != 0)
                row_set = new array of string[0,0]
                hdr_set = new array of string[ 0 ]

                return row_set

            /*
             * Retrieving the result set object,
             * containing both table headers and rows.
             */
            res_set: Result = dbcnx.store_result()

            if ((res_set == null) || (dbcnx.errno() != 0))
                row_set = new array of string[0,0]
                hdr_set = new array of string[ 0 ]

                return row_set

            var num_rows = res_set.num_rows()
            var num_hdrs = res_set.num_fields()
#elif (POSTGRES)
            // Preparing the SQL statement.
            res_set:Result = dbcnx.prepare(aux._EMPTY_STRING, sql_select, null)

            if ((res_set == null)
                || (res_set.get_status() != ExecStatus.COMMAND_OK))

                row_set = new array of string[0,0]
                hdr_set = new array of string[ 0 ]

                return row_set

            // Executing the SQL statement.
            res_set = dbcnx.exec_prepared(aux._EMPTY_STRING, 0, null, null,
                                                       null, 0)

            if ((res_set == null)
                || (res_set.get_status() != ExecStatus.TUPLES_OK))

                row_set = new array of string[0,0]
                hdr_set = new array of string[ 0 ]

                return row_set

            var num_rows = res_set.get_n_tuples()
            var num_hdrs = res_set.get_n_fields()
#elif (SQLITE)
            stmt: Statement

            // Preparing the SQL statement.
            var ret = dbcnx.prepare_v2(sql_select, sql_select.length,out(stmt))

            if ((ret != OK) || (stmt == null))
                row_set = new array of string[0,0]
                hdr_set = new array of string[ 0 ]

                return row_set

            // FIXME: Ugly but workable... but ugly. -------------------------+
            var num_rows = 0           //                                     |
            while (stmt.step() == ROW) //                                     |
                num_rows++             // <-----------------------------------+

            var num_hdrs = stmt.column_count()
#endif

            if (num_rows == 0)
                row_set = new array of string[0,0]
                hdr_set = new array of string[ 0 ]

                return row_set

            // Allocating the hdr_set array before populating it.
            hdr_set.resize((int) num_hdrs)

            // Retrieving and processing the result set metadata--table headers
            for i: uint = 0 to (num_hdrs - 1)
#if   (MYSQL)
                hdr_set[i] = res_set.fetch_field().name
#elif (POSTGRES)
                hdr_set[i] = res_set.get_field_name((int) i)
#elif (SQLITE)
                hdr_set[i] = stmt.column_name((int) i)
#endif

            /*
             * Note: Since the error "The name `resize' does not exist
             *       in the context of `string[,]?'", it needs to allocate
             *       2D-array using a constructor:
             */
            row_set = new array of string[num_rows,num_hdrs]

            // Retrieving and processing the result set -- table rows.
#if   (!SQLITE)
            for i: uint = 0 to (num_rows - 1)
#else
            i: uint = 0

            while (stmt.step() == ROW)
#endif

#if   (MYSQL)
                var row_ary = res_set.fetch_row()
#endif

                for j: uint = 0 to (num_hdrs - 1)
#if   (MYSQL)
                    row_set[i,j] = row_ary[j]
#elif (POSTGRES)
                    row_set[i,j] = res_set.get_value((int) i, (int) j)
#elif (SQLITE)
                    row_set[i,j] = stmt.column_text((int) j)
#endif

#if   (!POSTGRES)
                    if (row_set[i,j] == null)
                        row_set[i,j] = aux._EMPTY_STRING
#endif

#if   (SQLITE)
                i++
#endif

            return row_set

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
        def get_data_items_by_date(from: string,
                                   to  : string,
                                  dbcnx: Database,
                            out hdr_set: array of string[]): array of string[,]

            var row_set = new array of string[0,0]
                hdr_set = new array of string[ 0 ]

            // Instantiating the controller helper class.
            var aux = new ControllerHelper()

            var sql_select = ("select"
                + "      x0.name as arch,"
                + "      x1.name as repo,"
                + "   items.name,"
                + " attr_x2      as version,"
//              + "   items.description,"
                + " attr_x3      as last_updated,"
                + " attr_x4      as flag_date"
            + " from"
                + " data_items items,"
                + "   attr_x0s x0,"
                + "   attr_x1s x1"
            + " where"
                + " (attr_x0_id = x0.id) and"
                + " (attr_x1_id = x1.id) and")
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
#if   (POSTGRES)
//          sql_select += (" (attr_x3 >=  $1) and"
//                     +   " (attr_x3 <=  $2)")
// ----------------------------------------------------------------------------

            sql_select +=  " (attr_x3 between  $1 and  $2)"
// ----------------------------------------------------------------------------
#else
//          sql_select += (" (attr_x3 >= '?') and"
//                     +   " (attr_x3 <= '?')")
// ----------------------------------------------------------------------------

            sql_select +=  " (attr_x3 between '?' and '?')"
// ----------------------------------------------------------------------------
#endif
            sql_select += (" order by"
                + " items.name,"
                + "       arch")

#if   (MYSQL)
            // Binding values to SQL placeholders.
            sql_select = sql_select.replace(aux._QM,aux._S_FMT).printf(from,to)

            // Executing the SQL statement.
            var ret = dbcnx.real_query(sql_select, sql_select.length)

            if (ret != 0)
                row_set = new array of string[0,0]
                hdr_set = new array of string[ 0 ]

                return row_set

            /*
             * Retrieving the result set object,
             * containing both table headers and rows.
             */
            res_set: Result = dbcnx.store_result()

            if ((res_set == null) || (dbcnx.errno() != 0))
                row_set = new array of string[0,0]
                hdr_set = new array of string[ 0 ]

                return row_set

            var num_rows = res_set.num_rows()
            var num_hdrs = res_set.num_fields()
#elif (POSTGRES)
            // Preparing the SQL statement.
            res_set:Result = dbcnx.prepare(aux._EMPTY_STRING, sql_select, null)

            if ((res_set == null)
                || (res_set.get_status() != ExecStatus.COMMAND_OK))

                row_set = new array of string[0,0]
                hdr_set = new array of string[ 0 ]

                return row_set

            // Executing the SQL statement.
            res_set = dbcnx.exec_prepared(aux._EMPTY_STRING, 2, {from, to},
                                                 null, null, 0)

            if ((res_set == null)
                || (res_set.get_status() != ExecStatus.TUPLES_OK))

                row_set = new array of string[0,0]
                hdr_set = new array of string[ 0 ]

                return row_set

            var num_rows = res_set.get_n_tuples()
            var num_hdrs = res_set.get_n_fields()
#elif (SQLITE)
            /*
             * Removing single quotation marks from SQL placeholders
             * (preprocessing).
             */
            sql_select = sql_select.replace(aux._SQ, aux._EMPTY_STRING)

            stmt: Statement

            // Preparing the SQL statement.
            var ret = dbcnx.prepare_v2(sql_select, sql_select.length,out(stmt))

            if ((ret != OK) || (stmt == null))
                row_set = new array of string[0,0]
                hdr_set = new array of string[ 0 ]

                return row_set

            // Binding values to SQL placeholders.
            stmt.bind_text(1, from)
            stmt.bind_text(2,   to)

            // FIXME: Ugly but workable... but ugly. -------------------------+
            var num_rows = 0           //                                     |
            while (stmt.step() == ROW) //                                     |
                num_rows++             // <-----------------------------------+

            var num_hdrs = stmt.column_count()
#endif

            if (num_rows == 0)
                row_set = new array of string[0,0]
                hdr_set = new array of string[ 0 ]

                return row_set

            // Allocating the hdr_set array before populating it.
            hdr_set.resize((int) num_hdrs)

            // Retrieving and processing the result set metadata--table headers
            for i: uint = 0 to (num_hdrs - 1)
#if   (MYSQL)
                hdr_set[i] = res_set.fetch_field().name
#elif (POSTGRES)
                hdr_set[i] = res_set.get_field_name((int) i)
#elif (SQLITE)
                hdr_set[i] = stmt.column_name((int) i)
#endif

            // Allocating the row_set array before populating it.
            row_set = new array of string[num_rows,num_hdrs]

            // Retrieving and processing the result set -- table rows.
#if   (!SQLITE)
            for i: uint = 0 to (num_rows - 1)
#else
            i: uint = 0

            while (stmt.step() == ROW)
#endif

#if   (MYSQL)
                var row_ary = res_set.fetch_row()
#endif

                for j: uint = 0 to (num_hdrs - 1)
#if   (MYSQL)
                    row_set[i,j] = row_ary[j]
#elif (POSTGRES)
                    row_set[i,j] = res_set.get_value((int) i, (int) j)
#elif (SQLITE)
                    row_set[i,j] = stmt.column_text((int) j)
#endif

#if   (!POSTGRES)
                    if (row_set[i,j] == null)
                        row_set[i,j] = aux._EMPTY_STRING
#endif

#if   (SQLITE)
                i++
#endif

            return row_set

        /** Default constructor. */
        construct()
            pass

// vim:set nu:et:ts=4:sw=4:

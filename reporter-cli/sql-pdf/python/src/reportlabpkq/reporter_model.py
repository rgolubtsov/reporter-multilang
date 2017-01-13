# -*- coding: utf-8 -*-
# reporter-cli/sql-pdf/python/src/reportlabpkq/reporter_model.py
# =============================================================================
# Reporter Multilang. Version 0.1
# =============================================================================
# A tool to generate human-readable reports based on data from various sources
# with the focus on its implementation using a series of programming languages.
# =============================================================================
# Written by Radislav (Radicchio) Golubtsov, 2016-2017
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# (See the LICENSE file at the top of the source tree.)
#

from reportlabpkq.controller_helper import ControllerHelper

class ReporterModel:
    """The model class of the application."""

    def get_all_data_items(self, cnx, mysql=False):
        """Retrieves a list of all data items stored in the database.

        Args:
            cnx: The database connection object.

        Kwargs:
            mysql: The indicator that shows whether the database connection
                   object is MySQL connection.
                   (Default is False)

        Returns:
            References to two arrays containing table headers and rows.
        """

        # Instantiating the controller helper class.
        aux = ControllerHelper()

        sql_select = ("select"
                "      x0.name as arch,"
                "      x1.name as repo,"
                "   items.name,"
                " attr_x2      as version,"
#               "   items.description,"
                " attr_x3      as last_updated,"
                " attr_x4      as flag_date"
            " from"
                " data_items items,"
                "   attr_x0s x0,"
                "   attr_x1s x1"
            " where"
                " (attr_x0_id  = x0.id) and"
                " (attr_x1_id  = x1.id)" # and"
#               " (attr_x4 is not null)"
            " order by"
                " items.name,"
                "       arch")

        # Preparing the SQL statement.
        if (mysql):
            cursor = cnx.cursor(prepared=True)
        else:
            cursor = cnx.cursor()

        cursor.execute(sql_select)

        # Retrieving the result set metadata -- table headers.
        hdr_set = []

        if (mysql):
            hdr_set   = cursor.column_names
        else:
            hdr_descr = cursor.description
            hdr_len   = len(hdr_descr)

            i = 0

            while (hdr_len - i):
                hdr_set.append(hdr_descr[i][0])

                i += 1

        # Retrieving the result set itself -- table rows.
        # Note: If the cursor.fetchall() method is used, the following block
        #       between dash separators is not needed at all.
#       row_set = cursor.fetchall()

        # ---------------------------------------------------------------------
        # The result set. Finally it will be a quasi-two-dimensional array.
        row_set = [] # <== Declare it as an initially empty.

        # Fetching the first row.
        row_ary = cursor.fetchone()

        # Retrieving and processing the result set -- table rows.
        while (row_ary):
            # Transforming tuples into arrays.
            row_ary = list(row_ary)

            i = 0

            # Erasing 'None' from row_ary cells (if any).
            while (i < len(row_ary)):
                if (row_ary[i] is None):
                    row_ary[i] = aux._EMPTY_STRING

                i += 1

            row_set.append(row_ary)

            # Fetching the next row.
            row_ary = cursor.fetchone()
        # ---------------------------------------------------------------------

        cursor.close()

        return (hdr_set, row_set)

    def get_data_items_by_date(self, morf, to, cnx, mysql=False, postgres=False):
        """Retrieves a list of data items for a given date period.

        Args:
            morf: The start date to retrieve data set.
            to:   The end   date to retrieve data set.
            cnx:  The database connection object.

        Kwargs:
            mysql:    The indicator that shows whether the database connection
                      object is MySQL connection.
                      (Default is False)
            postgres: The indicator that shows whether the database connection
                      object is PostgreSQL connection.
                      (Default is False)

        Returns:
            References to two arrays containing table headers and rows.
        """

        # Instantiating the controller helper class.
        aux = ControllerHelper()

        sql_select = ("select"
                "      x0.name as arch,"
                "      x1.name as repo,"
                "   items.name,"
                " attr_x2      as version,"
#               "   items.description,"
                " attr_x3      as last_updated,"
                " attr_x4      as flag_date"
            " from"
                " data_items items,"
                "   attr_x0s x0,"
                "   attr_x1s x1"
            " where"
                " (attr_x0_id  = x0.id) and"
                " (attr_x1_id  = x1.id) and")
# -----------------------------------------------------------------------------
# Note: PostgreSQL driver (psycopg2) can handle only universal Python
#       placeholders (%s), whilst SQLite module can handle only question-mark-
#       placeholders (?). MySQL connector can do both. So that the use
#       of universal Python placeholders is mandatory only for PostgreSQL ops.
# -----------------------------------------------------------------------------
        if (postgres):
#           sql_select += (" (attr_x3 >= %s) and"
#                          " (attr_x3 <= %s)")
# -----------------------------------------------------------------------------
            sql_select +=  " (attr_x3 between %s and %s)"
# -----------------------------------------------------------------------------
        else:
#           sql_select += (" (attr_x3 >=  ?) and"
#                          " (attr_x3 <=  ?)")
# -----------------------------------------------------------------------------
            sql_select +=  " (attr_x3 between  ? and  ?)"
# -----------------------------------------------------------------------------
        sql_select += (" order by"
                           " items.name,"
                           "       arch")

        # Preparing the SQL statement.
        if (mysql):
            cursor = cnx.cursor(prepared=True)
        else:
            cursor = cnx.cursor()

        cursor.execute(sql_select, (morf, to))

        # Retrieving the result set metadata -- table headers.
        hdr_set = []

        if (mysql):
            hdr_set   = cursor.column_names
        else:
            hdr_descr = cursor.description
            hdr_len   = len(hdr_descr)

            i = 0

            while (hdr_len - i):
                hdr_set.append(hdr_descr[i][0])

                i += 1

        # Retrieving the result set itself -- table rows.
        # Note: If the cursor.fetchall() method is used, the following block
        #       between dash separators is not needed at all.
#       row_set = cursor.fetchall()

        # ---------------------------------------------------------------------
        # The result set. Finally it will be a quasi-two-dimensional array.
        row_set = [] # <== Declare it as an initially empty.

        # Fetching the first row.
        row_ary = cursor.fetchone()

        # Retrieving and processing the result set -- table rows.
        while (row_ary):
            # Transforming tuples into arrays.
            row_ary = list(row_ary)

            i = 0

            # Erasing 'None' from row_ary cells (if any).
            while (i < len(row_ary)):
                if (row_ary[i] is None):
                    row_ary[i] = aux._EMPTY_STRING

                i += 1

            row_set.append(row_ary)

            # Fetching the next row.
            row_ary = cursor.fetchone()
        # ---------------------------------------------------------------------

        cursor.close()

        return (hdr_set, row_set)

    def __init__(self):
        """Default constructor."""

        self = []

        return None

# vim:set nu:et:ts=4:sw=4:

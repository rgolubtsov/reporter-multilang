# -*- coding: utf-8 -*-
# reporter-cli/sql-pdf/python/src/reportlabpkg.py
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

import mysql.connector
import psycopg2
import sqlite3

from reportlabpkq.controller_helper import ControllerHelper

class ReportLabPkg:
    """The main class of the application."""

    # Database switches. They indicate which database to connect to.
    _MY_CONNECT = "mysql"
    _PG_CONNECT = "postgres"
    _SL_CONNECT = "sqlite"

    ##
    # Constant: The database name.
    #    FIXME: Move to cli args.
    #
    DATABASE = "reporter_multilang"

    ##
    # Constant: The database server name.
    #    FIXME: Move to cli args.
    #
    HOSTNAME = "10.0.2.100"
    #HOSTNAME = "localhost"

    ##
    # Constant: The username to connect to the database.
    #    FIXME: Move to cli args.
    #
    USERNAME = "reporter"

    ##
    # Constant: The password to connect to the database.
    #    FIXME: Move to cli args.
    #
    PASSWORD = "retroper12345678"

    ##
    # Constant: The SQLite database location.
    #    FIXME: Move to cli args.
    #
    SQLITE_DB_DIR = "lib/data/"

    def startup(self, args):
        """Starts up the app.

        Args:
            args: The array of command-line arguments.

        Returns:
            The exit code indicating the app overall execution status.
        """

        # Instantiating the controller helper class.
        aux = ControllerHelper()

        ret = aux._EXIT_SUCCESS

        db_switch = args[0]

        cnx = None

        # Trying to connect to the database.
        try:
            if   (db_switch == self._MY_CONNECT):
                cnx = mysql.connector.connect(database=self.DATABASE,
                                                  host=self.HOSTNAME,
                                                  user=self.USERNAME,
                                              password=self.PASSWORD)
            elif (db_switch == self._PG_CONNECT):
                cnx =        psycopg2.connect(database=self.DATABASE,
                                                  host=self.HOSTNAME,
                                                  user=self.USERNAME,
                                              password=self.PASSWORD)
            elif (db_switch == self._SL_CONNECT):
                cnx =         sqlite3.connect(database=aux._CURRENT_DIR
                                                   + self.SQLITE_DB_DIR
                                                   + self.DATABASE)
        except mysql.connector.Error as e:
            ret = aux._EXIT_FAILURE

            print(__name__ + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                           + aux._COLON_SPACE_SEP + str(e))

            return ret

        # Instantiating the controller class.
#        ctrl = ReporterController()

        if (cnx):
            print(__name__ + aux._COLON_SPACE_SEP + str(cnx))

            # Generating the PDF report.
#            ret = ctrl.pdf_report_generate(cnx)

            # Disconnecting from the database.
            cnx.close()
        else:
            ret = aux._EXIT_FAILURE

            print(__name__ + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                           + aux._COLON_SPACE_SEP + aux._ERROR_NO_DB_CONNECT)

            return ret

        return ret

    def __init__(self):
        """Default constructor."""

        self = []

        return None

# vim:set nu:et:ts=4:sw=4:

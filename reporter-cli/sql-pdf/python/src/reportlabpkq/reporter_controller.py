# -*- coding: utf-8 -*-
# reporter-cli/sql-pdf/python/src/reportlabpkq/reporter_controller.py
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
from reportlabpkq.reporter_model    import ReporterModel

class ReporterController:
    """The controller class of the application."""

    ##
    # Constant: The start date to retrieve data set.
    #    FIXME: Move to cli args.
    #
    FROM = "2016-06-01"

    ##
    # Constant: The end   date to retrieve data set.
    #    FIXME: Move to cli args.
    #
    TO   = "2016-12-01"

    ##
    # Constant: The PDF report output location.
    #    FIXME: Move to cli args.
    #
    PDF_REPORT_DIR = "lib/data/"

    ##
    # Constant: The PDF report filename.
    #    FIXME: Move to cli args.
    #
    PDF_REPORT_FILENAME = "packages.pdf"

    ##
    # Constant: The number of pages generated in a PDF report.
    #    FIXME: Move to cli args.
    #
    MAX_PAGES = 20

    ## Constant: The PDF basic measurement unit -- PostScript point.
    PT =   1

    ## Constant: The one inch       (in PDF measurement terms).
    IN = ( 1   / 72)

    ## Constant: The one millimeter (in PDF measurement terms).
    MM = (25.4 / 72)

    ## Constant: The RGB normalizing divisor.
    FF = 255

    def pdf_report_generate(self, cnx, mysql=False):
        """Generates the PDF report.

        Args:
            cnx: The database connection object.

        Kwargs:
            mysql: The indicator that shows whether the database connection
                   object is MySQL connection.
                   (Default is False)

        Returns:
            The exit code indicating the status of generating the PDF report.
        """

        # Instantiating the controller helper class.
        aux = ControllerHelper()

        ret = aux._EXIT_SUCCESS

        # Instantiating the model class.
        model = ReporterModel()

        # Retrieving a list of all data items stored in the database.
        (hdr_set, row_set) = model.get_all_data_items(cnx, mysql)

        # ---------------------------------------------------------------------
        # --- Debug output - Begin --------------------------------------------
        # ---------------------------------------------------------------------
        print(__name__ + aux._COLON_SPACE_SEP + str(cnx)
                       + aux._COLON_SPACE_SEP + str(hdr_set)
                       + aux._COLON_SPACE_SEP + str(row_set))
        # ---------------------------------------------------------------------
        # --- Debug output - End ----------------------------------------------
        # ---------------------------------------------------------------------

        return ret

    def __init__(self):
        """Default constructor."""

        self = []

        return None

# vim:set nu:et:ts=4:sw=4:

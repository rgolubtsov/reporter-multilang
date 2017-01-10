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

import time

from prettytable      import PrettyTable
from reportlab.pdfgen import canvas

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
    PDF_REPORT_DIR = "data"

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

    # Various string literals.
    _ROWS_IN_SET_FOOTER   = " rows in set"
    _PDF_REPORT_SAVED_MSG = "PDF report saved"

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

        # In case of getting an empty result set, informing the user.
        if (not(row_set)):
            ret = aux._EXIT_FAILURE

            print(__name__ + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                           + aux._COLON_SPACE_SEP + aux._ERROR_NO_DATA)

            return ret

        # ---------------------------------------------------------------------
        # --- Debug output - Begin --------------------------------------------
        # ---------------------------------------------------------------------
        dbg_output = PrettyTable(hdr_set)

        # Populating table rows.
        # Note: For PostgreSQL and SQLite databases the following simple loop
        #       between dash separators is quite sufficient,
        #       but for MySQL database it needs to decode
        #       row_set cells.
        i = 0

        # ---------------------------------------------------------------------
        if (not(mysql)):
            # Simply traversing through row_set rows.
            while (i < len(row_set)):
                dbg_output.add_row(row_set[i])

                i += 1
        # ---------------------------------------------------------------------
        else:
            # Transforming tuples into arrays.
            while (i < len(row_set)):
                row_ary = list(row_set[i])

                j = 0

                # Decoding row_set cells.
                while (j < len(hdr_set)):
                    if ((j != 4) and (j != 5)):
                        row_ary[j] = row_ary[j].decode()

                    j += 1

                dbg_output.add_row(row_ary)

                i += 1

        print(dbg_output)

        print(str(len(row_set)) + self._ROWS_IN_SET_FOOTER + aux._NEW_LINE)
        # ---------------------------------------------------------------------
        # --- Debug output - End ----------------------------------------------
        # ---------------------------------------------------------------------

        time.sleep(1) # <== Waiting one second... just for fun... :-)... -- OK.

        # ---------------------------------------------------------------------
        # --- Generating the PDF report - Begin -------------------------------
        # ---------------------------------------------------------------------
        pdf_report_path = self._get_pdf_report_path(__file__, aux)

        report = canvas.Canvas(pdf_report_path)

        # TODO: Implement generating the PDF report.

        # Saving the report.
        report.save()

        print(self._PDF_REPORT_SAVED_MSG + aux._COLON_SPACE_SEP
                                         + pdf_report_path)
        # ---------------------------------------------------------------------
        # --- Generating the PDF report - End ---------------------------------
        # ---------------------------------------------------------------------

        return ret

    # Helper method.
    # Returns the generated PDF report output path,
    # relative to this module location.
    # TODO: Remove this method when the report output location
    #       will be passed through cli args.
    def _get_pdf_report_path(self, module, aux):
        module_path     = module.split(aux._SLASH)
        module_name     = module_path.pop()
        package_name    = module_path.pop()
        pdf_report_path = (aux._SLASH.join(module_path)
                        +  aux._SLASH + self.PDF_REPORT_DIR
                        +  aux._SLASH + self.PDF_REPORT_FILENAME)

        return pdf_report_path

    def __init__(self):
        """Default constructor."""

        self = []

        return None

# vim:set nu:et:ts=4:sw=4:

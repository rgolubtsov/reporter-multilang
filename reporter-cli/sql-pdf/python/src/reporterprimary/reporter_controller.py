# -*- coding: utf-8 -*-
# reporter-cli/sql-pdf/python/src/reporterprimary/reporter_controller.py
# =============================================================================
# Reporter Multilang. Version 0.1
# =============================================================================
# A tool to generate human-readable reports based on data from various sources
# with the focus on its implementation using a series of programming languages.
# =============================================================================
# Written by Radislav (Radicchio) Golubtsov, 2016-2019
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

from prettytable             import PrettyTable
from reportlab.pdfgen        import canvas
from reportlab.lib.pagesizes import A4

from reporterprimary.controller_helper import ControllerHelper
from reporterprimary.reporter_model    import ReporterModel

class ReporterController:
    """The controller class of the application."""

    ##
    # Constant: The start date to retrieve data set.
    #     TODO: Move to cli args.
    #
    FROM = "2016-06-01"

    ##
    # Constant: The end   date to retrieve data set.
    #     TODO: Move to cli args.
    #
    TO   = "2016-12-01"

    ##
    # Constant: The PDF report output location.
    #     TODO: Move to cli args.
    #
    PDF_REPORT_DIR = "data"

    ##
    # Constant: The PDF report filename.
    #     TODO: Move to cli args.
    #
    PDF_REPORT_FILENAME = "packages.pdf"

    ##
    # Constant: The number of pages generated in a PDF report.
    #     TODO: Move to cli args.
    #
    MAX_PAGES = 20

    ## Constant: The maximum number of data rows displayed in a page.
    MAX_ROWS_IN_A_PAGE = 40

    ## Constant: The PDF basic measurement unit -- PostScript point.
    PT =   1

    ## Constant: The one inch       (in PDF measurement terms).
    IN = ( 1   / 72)

    ## Constant: The one millimeter (in PDF measurement terms).
    MM = (25.4 / 72)

    ## Constant: The RGB normalizing divisor.
    FF = 255

    # Various string literals.
    _REPORT_TITLE         = "Arch Linux Packages"
    _REPORT_AUTHOR        = "Arch Linux Package Maintainers"
    _REPORT_SUBJECT       = "Sample list of Arch Linux packages."
    _REPORT_KEYWORDS      =("Linux ArchLinux Packages Arch Repo "
                          + "core extra community multilib")
    _REPORT_CREATOR       =("Reporter Multilang 0.1 - "
                          + "https://github.com/rgolubtsov/"
                          + "reporter-multilang")
    # -------------------------------------------------------------------------
    _HELVETICA_BOLD_FONT  = "Helvetica-Bold"
    _HELVETICA_FONT       = "Helvetica"
    _TIMES_BOLD_FONT      = "Times-Bold"
    # -------------------------------------------------------------------------
    _ARCH_HEADER          = "Arch"
    _REPO_HEADER          = "Repo"
    _NAME_HEADER          = "Name"
    _VERSION_HEADER       = "Version"
    _LAST_UPDATED_HEADER  = "Last Updated"
    _FLAG_DATE_HEADER     = "Flag Date"
    # -------------------------------------------------------------------------
    _ROWS_IN_SET_FOOTER   = " rows in set"
    _ROWS_SHOWN_FOOTER    = "  (" + str(MAX_ROWS_IN_A_PAGE) + " rows shown)"
    _PDF_REPORT_SAVED_MSG = "PDF report saved"

    def pdf_report_generate(self, cnx, mysql=False, postgres=False):
        """Generates the PDF report.

        Args:
            cnx: The database connection object.

        Kwargs:
            mysql:    The indicator that shows whether the database connection
                      object is MySQL connection.
                      (Default is False)
            postgres: The indicator that shows whether the database connection
                      object is PostgreSQL connection.
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
#       (hdr_set, row_set) = model.get_all_data_items(cnx, mysql)

        # Retrieving a list of data items for a given date period.
        (hdr_set, row_set) = model.get_data_items_by_date(self.FROM, self.TO,
                                                          cnx, mysql, postgres)

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
            # Traversing through row_set rows with cells post-processing.
            while (i < len(row_set)):
                row_ary = row_set[i]

                j = 0

                # Decoding row_set cells.
                while (j < len(hdr_set)):
                    if ((j != 4) and (j != 5)):
                        row_ary[j] = row_ary[j].decode()

                    j += 1

                dbg_output.add_row(row_ary)

                i += 1

        # Left-aligning table columns.
        dbg_output.align="l"

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

        report = canvas.Canvas(pdf_report_path,
                               pagesize=A4,     # <== 210 x 297 mm.
                             pdfVersion=(1, 4), # <== PDF version 1.4.
        # --- Page boxes ------------------------------------------------------
# cropBox=( (10 / self.MM),  (10 / self.MM), (200 / self.MM), (287 / self.MM)),
#  artBox=( (15 / self.MM),  (15 / self.MM), (195 / self.MM), (282 / self.MM)),
# trimBox=((210 / self.MM), (297 / self.MM)                                  ),
#bleedBox=(  (5 / self.MM),   (5 / self.MM), (205 / self.MM), (292 / self.MM))
                              )

        # --- Report metadata -------------------------------------------------
        report.setTitle   (self._REPORT_TITLE   )
        report.setAuthor  (self._REPORT_AUTHOR  )
        report.setSubject (self._REPORT_SUBJECT )
        report.setKeywords(self._REPORT_KEYWORDS)
        report.setCreator (self._REPORT_CREATOR )

        # --- Page body (data) x MAX_PAGES ------------------------------------
        i = 0

        while (i < self.MAX_PAGES):
            ret = self._page_body_draw(report, hdr_set, row_set)

            if (ret == aux._EXIT_FAILURE):
                print(__name__ + aux._COLON_SPACE_SEP+aux._ERROR_PREFIX
                               + aux._COLON_SPACE_SEP+aux._ERROR_NO_REPORT_GEN)

                return ret

            report.showPage()

            i += 1

        # Trying to save the report.
        try:
            report.save()
        except Exception as e:
            ret = aux._EXIT_FAILURE

            print(__name__ + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                           + aux._COLON_SPACE_SEP + str(e))

            return ret

        print(self._PDF_REPORT_SAVED_MSG + aux._COLON_SPACE_SEP
                                         + pdf_report_path)
        # ---------------------------------------------------------------------
        # --- Generating the PDF report - End ---------------------------------
        # ---------------------------------------------------------------------

        return ret

    # Draws the PDF report page body (data).
    def _page_body_draw(self, report, hdr_set, row_set):
        # Instantiating the controller helper class.
        aux = ControllerHelper()

        ret = aux._EXIT_SUCCESS

        table_headers = {}

        # --- Border ----------------------------------------------------------

        report.setStrokeColorRGB(( 34 / self.FF),      # <== _RAINY_NIGHT_COLOR
                                 ( 68 / self.FF),      #              (#224488)
                                 (136 / self.FF))

        report.setLineWidth(2)

        report.rect(( 16 / self.MM),
                    ( 19 / self.MM),
                    (178 / self.MM),
                    (259 / self.MM))

        # --- Headers bar -----------------------------------------------------

        report.setFillColorRGB(( 34 / self.FF),        # <== _RAINY_NIGHT_COLOR
                               ( 68 / self.FF),        #              (#224488)
                               (136 / self.FF))

        report.rect(( 17 / self.MM),
                    (267 / self.MM),
                    (176 / self.MM),
                    ( 10 / self.MM), stroke=0, fill=1)

        # --- Headers txt -----------------------------------------------------

        report.setFont(self._HELVETICA_BOLD_FONT, (16 / self.PT))

        report.setFillColorRGB((255 / self.FF),              # <== _WHITE_COLOR
                               (255 / self.FF),              #        (#ffffff)
                               (255 / self.FF))

        table_headers[hdr_set[0]] = self._ARCH_HEADER
        table_headers[hdr_set[1]] = self._REPO_HEADER
        table_headers[hdr_set[2]] = self._NAME_HEADER
        table_headers[hdr_set[3]] = self._VERSION_HEADER
        table_headers[hdr_set[4]] = self._LAST_UPDATED_HEADER
        table_headers[hdr_set[5]] = self._FLAG_DATE_HEADER

        x = 0

        i = 0

        # Printing table headers.
        while (i < len(hdr_set)):
            if   (i == 1):
                x =  17
            elif (i == 2):
                x =  40
            elif (i == 3):
                x =  78
            elif (i == 4):
                x = 107
            elif (i == 5):
                x = 146
            else: # <== Includes (i == 0).
                x =   0

            report.drawString(((20 + x) / self.MM),
                              (270      / self.MM), table_headers[hdr_set[i]])

            i += 1

        # --- Table rows ------------------------------------------------------

        report.setFont(self._HELVETICA_FONT, (11 / self.PT))

        y = 0

        i = 0

        # Printing table rows.
#       while (i <            len(row_set)):
        while (i < self.MAX_ROWS_IN_A_PAGE):
            if (i & 1):
                report.setFillColorRGB((221 / self.FF),  # <== _RAINY_DAY_COLOR
                                       (221 / self.FF),  #            (#dddddd)
                                       (221 / self.FF))

                report.rect((  17      / self.MM),
                            ((260 - y) / self.MM),
                            ( 176      / self.MM),
                            (   6      / self.MM), stroke=0, fill=1)

            report.setFillColorRGB((0 / self.FF),            # <== _BLACK_COLOR
                                   (0 / self.FF),            #        (#000000)
                                   (0 / self.FF))

            j = 0

            while (j < len(hdr_set)):
                if   (j == 1):
                    x =  17
                elif (j == 2):
                    x =  40
                elif (j == 3):
                    x =  78
                elif (j == 4):
                    x = 123
                elif (j == 5):
                    x = 148
                else: # <== Includes (j == 0).
                    x =   0

                if (row_set[i][j] is not None):
                    row_set_cell = str(row_set[i][j])
                else:
                    row_set_cell = aux._EMPTY_STRING

                report.drawString(((20 + x) / self.MM),
                                 ((262 - y) / self.MM), row_set_cell)

                j += 1

            i += 1

            y += 6

        # --- Footer bar ------------------------------------------------------

        report.setFillColorRGB((170 / self.FF),  # <== _VERY_LIGHT_COBALT_COLOR
                               (170 / self.FF),  #                    (#aaaaaa)
                               (170 / self.FF))

        report.rect(( 17 / self.MM),
                    ( 20 / self.MM),
                    (176 / self.MM),
                    (  6 / self.MM), stroke=0, fill=1)

        # --- Footer txt ------------------------------------------------------

        report.setFont(self._TIMES_BOLD_FONT, (12 / self.PT))

        report.setFillColorRGB((238 / self.FF),      # <== _YET_NOT_WHITE_COLOR
                               (238 / self.FF),      #                (#eeeeee)
                               (238 / self.FF))

        report.drawString((20 / self.MM),
                          (22 / self.MM), str(len(row_set))
                          + self._ROWS_IN_SET_FOOTER + self._ROWS_SHOWN_FOOTER)

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

# vim:set nu et ts=4 sw=4:

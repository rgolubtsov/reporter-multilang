[indent=4]
/* reporter-cli/sql-pdf/genie/src/reporter_controller.gs
 * ============================================================================
 * Reporter Multilang. Version 0.1
 * ============================================================================
 * A tool to generate human-readable reports based on data from various sources
 * with the focus on its implementation using a series of programming languages
 * ============================================================================
 * Written by Radislav (Radicchio) Golubtsov, 2016-2020
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

uses Cairo

namespace CliSqlPdf
    /** The controller class of the application. */
    class ReporterController
        /**
         * Constant: The start date to retrieve data set.
         *     TODO: Move to cli args.
         */
        const FROM: string = "2016-06-01"

        /**
         * Constant: The end   date to retrieve data set.
         *     TODO: Move to cli args.
         */
        const TO  : string = "2016-12-01"

        /**
         * Constant: The PDF report output location.
         *     TODO: Move to cli args.
         */
        const PDF_REPORT_DIR: string = "lib/data"

        /**
         * Constant: The PDF report filename.
         *     TODO: Move to cli args.
         */
        const PDF_REPORT_FILENAME: string = "packages.pdf"

        /**
         * Constant: The number of pages generated in a PDF report.
         *     TODO: Move to cli args.
         */
        const MAX_PAGES: uint = 20

        /** Constant: The maximum number of data rows displayed in a page. */
        const MAX_ROWS_IN_A_PAGE: uint = 40

        /** Constant: The PDF basic measurement unit -- PostScript point. */
        const PT: uint   =   1

        /** Constant: The one inch       (in PDF measurement terms). */
        const IN: double = ( 1   / 72)

        /** Constant: The one millimeter (in PDF measurement terms). */
        const MM: double = (25.4 / 72)

        /** Constant: The RGB normalizing divisor. */
        const FF: double = 255

        /** Constant: The vertical coordinate flipping normalizer. */
        const ZZ: uint   = 297

        /* Various string literals. */
        const  _REPORT_TITLE       : string =  "Arch Linux Packages"
        const  _REPORT_AUTHOR      : string =  "Arch Linux Package Maintainers"
        const  _REPORT_SUBJECT     : string = ("Sample list of Arch Linux "
                                            +  "packages.")
        const  _REPORT_KEYWORDS    : string = ("Linux ArchLinux Packages Arch "
                                            +  "Repo core extra community "
                                            +  "multilib")
        const  _REPORT_CREATOR     : string = ("Reporter Multilang 0.1 - "
                                            +  "https://github.com/rgolubtsov/"
                                            +  "reporter-multilang")
        // --------------------------------------------------------------------
        // --- /usr/share/fonts/100dpi/helv*.pcf.gz ------------
//      const _SANS_FONT           : string = "Helvetica"
        // --- /usr/share/fonts/TTF/DejaVuSan*.ttf -------------
//      const _SANS_FONT           : string = "DejaVu Sans"
        // --- /usr/share/fonts/TTF/LiberationSan*.ttf ---------
        const _SANS_FONT           : string = "Liberation Sans"
        // --- /usr/share/fonts/100dpi/tim*.pcf.gz -------------
//      const _SERIF_FONT          : string = "Times"
        // --- /usr/share/fonts/TTF/DejaVuSeri*.ttf ------------
//      const _SERIF_FONT          : string = "DejaVu Serif"
        // --- /usr/share/fonts/TTF/LiberationSeri*.ttf --------
        const _SERIF_FONT          : string = "Liberation Serif"
        // --------------------------------------------------------------------
        const _ARCH_HEADER         : string = "Arch"
        const _REPO_HEADER         : string = "Repo"
        const _NAME_HEADER         : string = "Name"
        const _VERSION_HEADER      : string = "Version"
        const _LAST_UPDATED_HEADER : string = "Last Updated"
        const _FLAG_DATE_HEADER    : string = "Flag Date"
        // --------------------------------------------------------------------
        const _ROWS_IN_SET_FOOTER  : string = " rows in set"
        const _ROWS_SHOWN_FOOTER_1 : string = "  ("
        const _ROWS_SHOWN_FOOTER_2 : string = " rows shown)"
        const _PDF_REPORT_SAVED_MSG: string = "PDF report saved"

        /**
         * Generates the PDF report.
         *
         * @param dbcnx The database handle object.
         * @param exec  The executable path.
         *
         * @return The exit code indicating the status
         *         of generating the PDF report.
         */
        def pdf_report_generate(dbcnx: Database, exec: string): int
            ret: int = Posix.EXIT_SUCCESS

            __name__: string = typeof(ReporterController).name()

            // Instantiating the controller helper class.
            var aux = new ControllerHelper()

            var __file__ = exec

            // Instantiating the model class.
            var model = new ReporterModel()

            var hdr_set = new array of string[0]

            // Retrieving a list of all data items stored in the database.
//          var row_set = model.get_all_data_items(dbcnx, out(hdr_set))

            // Retrieving a list of data items for a given date period.
            var row_set = model.get_data_items_by_date(FROM, TO,
                                                   dbcnx, out(hdr_set))

            var num_rows = row_set.length[0]
            var num_hdrs = row_set.length[1]

            // In case of getting an empty result set, informing the user.
            if (num_hdrs == 0)
                ret = Posix.EXIT_FAILURE

                stdout.printf(aux._S_FMT, __name__
                            + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                            + aux._COLON_SPACE_SEP + aux._ERROR_NO_DATA
                                                   + aux._NEW_LINE)

                return ret

            // ----------------------------------------------------------------
            // --- Debug output - Begin ---------------------------------------
            // ----------------------------------------------------------------
            var dbg_output = new TabularDisplay(hdr_set)

            dbg_output.populate(row_set)

            stdout.printf(aux._S_FMT, dbg_output.render())

            stdout.printf(aux._S_FMT,num_rows.to_string() + _ROWS_IN_SET_FOOTER
                                          + aux._NEW_LINE + aux._NEW_LINE)
            // ----------------------------------------------------------------
            // --- Debug output - End -----------------------------------------
            // ----------------------------------------------------------------

            Posix.sleep(1) //<==Waiting one second...just for fun...:-)...--OK.

            // ----------------------------------------------------------------
            // --- Generating the PDF report - Begin --------------------------
            // ----------------------------------------------------------------
            var pdf_report_path = _get_pdf_report_path(__file__, aux)

            var _report = new PdfSurface(pdf_report_path, (210 / MM),
                                                          (297 / MM))

            _report.restrict_to_version(PdfVersion.VERSION_1_4)

            // --- Report metadata --------------------------------------------
            /*
             * Note: The possibility to inject PDF metadata entries
             *       has appeared in Cairo 1.16, but even in Arch Linux
             *       the "cairo" package currently is just of version 1.14.8.
             *       And, of course, its Vala bindings are in the same state.
             *       After upgrading to Cairo 1.16+ appropriate calls should
             *       look something like the given below
             *       (commented out for now).
             *
             * See for reference:
             *   - Cairo sources:
             *       https://cgit.freedesktop.org/cairo/tree/src/cairo-pdf.h
             *       https://cgit.freedesktop.org/cairo/tree/src/
             *                                           cairo-pdf-surface.c
             *
             *   - Cairo Valadoc:
             *       https://valadoc.org/cairo/Cairo.PdfSurface.html
             */
//          _report.set_metadata(PdfMetadata.TITLE,    _REPORT_TITLE   )
//          _report.set_metadata(PdfMetadata.AUTHOR,   _REPORT_AUTHOR  )
//          _report.set_metadata(PdfMetadata.SUBJECT,  _REPORT_SUBJECT )
//          _report.set_metadata(PdfMetadata.KEYWORDS, _REPORT_KEYWORDS)
//          _report.set_metadata(PdfMetadata.CREATOR,  _REPORT_CREATOR )

            var report = new Cairo.Context(_report)

            // --- Page body (data) x MAX_PAGES -------------------------------
            for i: uint = 0 to (MAX_PAGES - 1)
                ret = _page_body_draw(report, hdr_set, row_set, num_hdrs,
                                                                num_rows)

                if (ret == Posix.EXIT_FAILURE)
                    stdout.printf(aux._S_FMT, __name__
                              + aux._COLON_SPACE_SEP + aux._ERROR_PREFIX
                              + aux._COLON_SPACE_SEP + aux._ERROR_NO_REPORT_GEN
                                                     + aux._NEW_LINE)

                    return ret

                report.show_page()

            stdout.printf(aux._S_FMT,_PDF_REPORT_SAVED_MSG+aux._COLON_SPACE_SEP
                                    + pdf_report_path     +aux._NEW_LINE)
            // ----------------------------------------------------------------
            // --- Generating the PDF report - End ----------------------------
            // ----------------------------------------------------------------

            return ret

        /* Draws the PDF report page body (data). */
        def _page_body_draw(report  : Cairo.Context,
                            hdr_set : array of string[ ],
                            row_set : array of string[,],
                            num_hdrs: uint,
                            num_rows: uint): int

            ret: int = Posix.EXIT_SUCCESS

            table_headers: HashTable of string, string = (
                       new HashTable of string, string(str_hash, str_equal))

            /*
             * Note: Without having this coordinate system translation
             *       it needs to utilize the vertical coordinate flipping
             *       normalizer (ZZ) to flip its y-coordinate where applicable.
             *    Q: What is it for? -- A: When using Cairo text API,
             *       it's quite sufficient to use the coordinate system
             *       translation. But when using Pango text API on top
             *       of Cairo, ZZ should be used instead.
             */
//          report.translate((0 / MM), (297 / MM))
//          report.scale(1, -1)

            // --- Border -----------------------------------------------------

            report.set_source_rgb(( 34 / FF),         // <== _RAINY_NIGHT_COLOR
                                  ( 68 / FF),         //              (#224488)
                                  (136 / FF))

            report.rectangle((16 / MM), (19 / MM), (178 / MM), (259 / MM))

            report.stroke()

            // --- Headers bar ------------------------------------------------

            report.set_source_rgb(( 34 / FF),         // <== _RAINY_NIGHT_COLOR
                                  ( 68 / FF),         //              (#224488)
                                  (136 / FF))

            report.rectangle((              17  / MM),
                             (((ZZ - 10) - 267) / MM),
                             (             176  / MM),
                             (              10  / MM))

            report.fill()

            // --- Headers txt ------------------------------------------------

            var font_descr = new Pango.FontDescription()

            font_descr.set_family(_SANS_FONT)

            font_descr.set_size((int)((12 / PT) * Pango.SCALE))

            font_descr.set_weight(Pango.Weight.SEMIBOLD)

            var layout = Pango.cairo_create_layout(report)

            layout.set_font_description(font_descr)

            // For Cairo-only output.
//          report.select_font_face(_SANS_FONT, FontSlant.NORMAL,
//                                              FontWeight.BOLD)
//          report.set_font_size((16 / PT))
//          var font_matrix = new Matrix.identity()
//          report.get_font_matrix(out(font_matrix))
//          font_matrix.scale(1, -1)
//          report.set_font_matrix(font_matrix)

            report.set_source_rgb((255 / FF),               // <== _WHITE_COLOR
                                  (255 / FF),               //        (#ffffff)
                                  (255 / FF))

            table_headers.insert(hdr_set[0], _ARCH_HEADER)
            table_headers.insert(hdr_set[1], _REPO_HEADER)
            table_headers.insert(hdr_set[2], _NAME_HEADER)
            table_headers.insert(hdr_set[3], _VERSION_HEADER)
            table_headers.insert(hdr_set[4], _LAST_UPDATED_HEADER)
            table_headers.insert(hdr_set[5], _FLAG_DATE_HEADER)

            x: uint = 0

            // Printing table headers.
            for i: uint = 0 to (num_hdrs - 1)
                if      (i == 1)
                    x =  17
                else if (i == 2)
                    x =  40
                else if (i == 3)
                    x =  78
                else if (i == 4)
                    x = 107
                else if (i == 5)
                    x = 146
                else // <== Includes (i == 0).
                    x =   0

                report.move_to(((20 + x) / MM), ((ZZ - 270) / MM))

                // Cairo-only output.
//              report.show_text(table_headers.lookup(hdr_set[i]))

                // Pango/Cairo output.
                // See for ref.: https://www.cairographics.org/FAQ/#using_pango
                layout.set_text(table_headers.lookup(hdr_set[i]), -1)
                Pango.cairo_show_layout_line(report,
                                             layout.get_line_readonly(0))

            // --- Table rows -------------------------------------------------

            font_descr.set_size((int)((8 / PT) * Pango.SCALE))

            font_descr.set_weight(Pango.Weight.NORMAL)

            layout.set_font_description(font_descr)

            // For Cairo-only output.
//          report.select_font_face(_SANS_FONT, FontSlant.NORMAL,
//                                              FontWeight.NORMAL)
//          report.set_font_size((11 / PT))
//          report.get_font_matrix(out(font_matrix))
//          font_matrix.scale(1, -1)
//          report.set_font_matrix(font_matrix)

            y: uint = 0

            // Printing table rows.
//          for i: uint = 0 to (num_rows           - 1)
            for i: uint = 0 to (MAX_ROWS_IN_A_PAGE - 1)
                if ((i & 1) == 1)
                    report.set_source_rgb((221 / FF),   // <== _RAINY_DAY_COLOR
                                          (221 / FF),   //            (#dddddd)
                                          (221 / FF))

                    report.rectangle((              17       / MM),
                                     (((ZZ - 6) - (260 - y)) / MM),
                                     (             176       / MM),
                                     (               6       / MM))

                    report.fill()

                report.set_source_rgb((0 / FF),             // <== _BLACK_COLOR
                                      (0 / FF),             //        (#000000)
                                      (0 / FF))

                for j: uint = 0 to (num_hdrs - 1)
                    if      (j == 1)
                        x =  17
                    else if (j == 2)
                        x =  40
                    else if (j == 3)
                        x =  78
                    else if (j == 4)
                        x = 123
                    else if (j == 5)
                        x = 148
                    else // <== Includes (j == 0).
                        x =   0

                    report.move_to(((20 + x) / MM), ((ZZ - (262 - y)) / MM))

                    // Cairo-only output.
//                  report.show_text(row_set[i,j])

                    // Pango/Cairo output.
                    layout.set_text(row_set[i,j], -1)
                    Pango.cairo_show_layout_line(report,
                                                 layout.get_line_readonly(0))

                y += 6

            // --- Footer bar -------------------------------------------------

            report.set_source_rgb((170 / FF),   // <== _VERY_LIGHT_COBALT_COLOR
                                  (170 / FF),   //                    (#aaaaaa)
                                  (170 / FF))

            report.rectangle((            17  / MM),
                             (((ZZ - 6) - 20) / MM),
                             (           176  / MM),
                             (             6  / MM))

            report.fill()

            // --- Footer txt -------------------------------------------------

            font_descr.set_family(_SERIF_FONT)

            font_descr.set_size((int)((9 / PT) * Pango.SCALE))

            font_descr.set_weight(Pango.Weight.SEMIBOLD)

            layout.set_font_description(font_descr)

            // For Cairo-only output.
//          report.select_font_face(_SERIF_FONT, FontSlant.NORMAL,
//                                               FontWeight.BOLD)
//          report.set_font_size((12 / PT))
//          report.get_font_matrix(out(font_matrix))
//          font_matrix.scale(1, -1)
//          report.set_font_matrix(font_matrix)

            report.set_source_rgb((238 / FF),       // <== _YET_NOT_WHITE_COLOR
                                  (238 / FF),       //                (#eeeeee)
                                  (238 / FF))

            report.move_to((20 / MM), ((ZZ - 22) / MM))

            // Cairo-only output.
//          report.show_text(num_rows.to_string() + _ROWS_IN_SET_FOOTER
//                      + _ROWS_SHOWN_FOOTER_1 + MAX_ROWS_IN_A_PAGE.to_string()
//                      + _ROWS_SHOWN_FOOTER_2)

            // Pango/Cairo output.
            layout.set_text(num_rows.to_string() + _ROWS_IN_SET_FOOTER
                        + _ROWS_SHOWN_FOOTER_1 + MAX_ROWS_IN_A_PAGE.to_string()
                        + _ROWS_SHOWN_FOOTER_2, -1)
            Pango.cairo_show_layout_line(report, layout.get_line_readonly(0))

            // ----------------------------------------------------------------

            return ret

        /*
         * Helper method.
         * Returns the generated PDF report output path,
         * relative to the executable's location.
         * TODO: Remove this method when the report output location
         *       will be passed through cli args.
         */
        def _get_pdf_report_path(exec: string, aux: ControllerHelper): string
            var exec_path = exec.split(aux._SLASH)

//          for i: uint = 0 to (exec_path.length - 1)
//              stdout.printf(aux._S_FMT, exec_path[i] + aux._NEW_LINE)

            exec_path.resize(exec_path.length - 1)
            exec_path       [exec_path.length - 1] = PDF_REPORT_DIR

//          for i: uint = 0 to (exec_path.length - 1)
//              stdout.printf(aux._S_FMT, exec_path[i] + aux._NEW_LINE)

            var pdf_report_path=(string.joinv(aux._SLASH, exec_path)
                                            + aux._SLASH + PDF_REPORT_FILENAME)

            return pdf_report_path

        /** Default constructor. */
        construct()
            pass

// vim:set nu et ts=4 sw=4:

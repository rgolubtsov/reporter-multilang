[indent=4]
/* reporter-cli/sql-pdf/genie/src/controller_helper.gs
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

namespace CliSqlPdf
    /** The helper for the controller class and related ones. */
    class ControllerHelper
        // Helper constants.
        const EMPTY_STRING   : string =   ""
        const NEW_LINE       : string = "\n"
        const S_FMT          : string = "%s"
        const COLON_SPACE_SEP: string = ": "
        const COLON          : string =  ":"
        const SLASH          : string =  "/"
        const AT             : string =  "@"
        const QM             : string =  "?"
        const SQ             : string =  "'"
        const V_BAR          : string =  "|"
        const SPACE          : string =  " "
        const SEP_NOD        : string =  "+"
        const SEP_COG        : string =  "-"
        const CURRENT_DIR    : string = "./"

        // Common error messages.
        const ERROR_PREFIX       : string = "Error"
        const ERROR_NO_DB_CONNECT: string = (
              "Could not connect to the database. ")
        const ERROR_NO_DATA      : string = "No data found."
        const ERROR_NO_REPORT_GEN: string = (
              "Could not generate the report.")

        /** Default constructor. */
        construct()
            pass

    /**
     * This class is a simplified Genie implementation of well-known and very
     * attractive Text::TabularDisplay Perl module by Darren Chamberlain:
     * http://search.cpan.org/~darren/Text-TabularDisplay-1.38/
     *                                     TabularDisplay.pm .
     *
     * The output is identical to that generated by the MySQL/MariaDB CLI
     * client when doing something like 'select ... from ... where ...;'
     * query on a database table.
     *
     * See Valadoc comments in respective methods for their proper usage.
     */
    class TabularDisplay
        /** The table headers (headings). */
        hdr_set: array of string[ ]

        /** The table rows (table body data). */
        row_set: array of string[,]

        /**
         * The finally consolidated tabular data,
         * which has to be printed to the client.
         */
        tableau: Array of string

        /**
         * Populates class data members with the given table data.
         *
         * @param _row_set The table rows (table body data).
         *                 (2D-array of strings.)
         */
        def populate(_row_set: array of string[,]): void
            var aux = new ControllerHelper()

            if (_row_set != null)
                var num_rows = _row_set.length[0]
                var num_hdrs = _row_set.length[1]

                row_set = new array of string[num_rows,num_hdrs]

                row_set = _row_set
                // ------------------------------------------------------------
                var hdr_set_len = new array of uint[         num_hdrs]
                var row_set_len = new array of uint[num_rows,num_hdrs]
                var col_max_len = new array of uint[num_rows         ]
                // ------------------------------------------------------------
                // Searching for the max data length in each column
                // to form its width.
                for j: uint = 0 to (num_hdrs - 1)
                    hdr_set_len[j] = hdr_set[j].length

                    for i: uint = 0 to (num_rows - 1)
                        row_set_len[i,j] = row_set[i,j].length

                    // Assuming this is the max.
                    col_max_len[j] = row_set_len[0,j]

                    // Searching for the max element in a column.
                    for i: uint = 0 to (num_rows - 1)
                        if (row_set_len[i,j] > col_max_len[j])
                            col_max_len[j] = row_set_len[i,j]
                // ------------------------------------------------------------
                _separator_draw(num_hdrs, hdr_set_len, col_max_len, aux)
                // ------------------------------------------------------------
                // Printing table headers.
                for i: uint = 0 to (num_hdrs - 1)
                    //stdout.printf(aux.S_FMT, aux.V_BAR+aux.SPACE+hdr_set[i])
                    tableau.append_val(        aux.V_BAR+aux.SPACE+hdr_set[i])

                    spacers: uint = 0

                    if (hdr_set_len[i] < col_max_len[i])
                        spacers = col_max_len[i] - hdr_set_len[i]

                    spacers++ // <== Additional spacer (padding).

                    for m: uint = 0 to (spacers - 1)
                        //stdout.printf(aux.S_FMT, aux.SPACE)
                        tableau.append_val(        aux.SPACE)

                //stdout.printf(aux.S_FMT, aux.V_BAR + aux.NEW_LINE)
                tableau.append_val(        aux.V_BAR + aux.NEW_LINE)
                // ------------------------------------------------------------
                _separator_draw(num_hdrs, hdr_set_len, col_max_len, aux)
                // ------------------------------------------------------------
                // Printing table rows.
                for i: uint = 0 to (num_rows - 1)
                    for j: uint = 0 to (num_hdrs - 1)
                        //stdout.printf(aux.S_FMT, aux.V_BAR + aux.SPACE
                        //                                   + row_set[i,j])
                        tableau.append_val(        aux.V_BAR + aux.SPACE
                                                             + row_set[i,j])

                        if (col_max_len[j] < hdr_set_len[j])
                            col_max_len[j] = hdr_set_len[j]

                        spacers: uint = 0

                        if (row_set_len[i,j] < col_max_len[j])
                            spacers = col_max_len[j] - row_set_len[i,j]

                        spacers++ // <== Additional spacer (padding).

                        for m: uint = 0 to (spacers - 1)
                            //stdout.printf(aux.S_FMT, aux.SPACE)
                            tableau.append_val(        aux.SPACE)

                    //stdout.printf(aux.S_FMT, aux.V_BAR + aux.NEW_LINE)
                    tableau.append_val(        aux.V_BAR + aux.NEW_LINE)
                // ------------------------------------------------------------
                _separator_draw(num_hdrs, hdr_set_len, col_max_len, aux)
                // ------------------------------------------------------------

            else
                row_set = new array of string[0,0]

        /**
         * Renders class data into string representation,
         * which is ready to be printed to the client.
         *
         * @return The string representation of collected tabular data.
         */
        def render(): string
            var aux = new ControllerHelper()

            tableau_str: string = aux.EMPTY_STRING

            if (tableau != null)
                for i: uint = 0 to (tableau.length - 1)
                    tableau_str += tableau.index(i)

            return tableau_str

        /* Helper method. Draws a horizontal separator for a table. */
        def _separator_draw(num_hdrs   : uint,
                            hdr_set_len: array of uint[],
                            col_max_len: array of uint[],
                            aux        : ControllerHelper): void

            for i: uint = 0 to (num_hdrs - 1)
                //stdout.printf(aux.S_FMT, aux.SEP_NOD)
                tableau.append_val(        aux.SEP_NOD)

                sep_len: uint = hdr_set_len[i]

                if (sep_len < col_max_len[i])
                    sep_len = col_max_len[i]

                sep_len += 2 // <== Two additional separator cogs (padding).

                for m: uint = 0 to (sep_len - 1)
                    //stdout.printf(aux.S_FMT, aux.SEP_COG)
                    tableau.append_val(        aux.SEP_COG)

            //stdout.printf(aux.S_FMT, aux.SEP_NOD + aux.NEW_LINE)
            tableau.append_val(        aux.SEP_NOD + aux.NEW_LINE)

        /**
         * Constructor. It takes one argument and returns an object instance
         *              of this class.
         *
         * @param _hdr_set The table headers (headings).
         *                 (Simple array of strings.)
         */
        construct(_hdr_set: array of string[])
            tableau = new Array of string()

            if (_hdr_set != null)
                hdr_set.resize(_hdr_set.length)

                hdr_set = _hdr_set
            else
                hdr_set = new array of string[0]

// vim:set nu:et:ts=4:sw=4:
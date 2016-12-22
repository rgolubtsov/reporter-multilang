# -*- coding: utf-8 -*-
# reporter-cli/sql-pdf/python/src/reportlabpkq/controller_helper.py
# =============================================================================
# Reporter Multilang. Version 0.1
# =============================================================================
# A tool to generate human-readable reports based on data from various sources
# with the focus on its implementation using a series of programming languages.
# =============================================================================
# Written by Radislav (Radicchio) Golubtsov, 2016
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

class ControllerHelper:
    """The helper for the controller class and related ones."""

    # Helper constants.
    _EXIT_FAILURE    =    1 #    Failing exit status.
    _EXIT_SUCCESS    =    0 # Successful exit status.
    _COLON_SPACE_SEP = ": "
    _CURRENT_DIR     = "./"
    _EMPTY_STRING    =   ""
    _NEW_LINE        = "\n"

    # Common error messages.
    _ERROR_PREFIX        = "Error"
    _ERROR_NO_DB_CONNECT = "Could not connect to the database."
    _ERROR_NO_DATA       = "No data found."
    _ERROR_NO_REPORT_GEN = "Could not generate the report."

    def __init__(self):
        """Default constructor."""

        self = []

        return None

# vim:set nu:et:ts=4:sw=4:

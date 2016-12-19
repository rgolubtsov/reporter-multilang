#
# reporter-core/sql-pdf/perl/src/PDFAPI2PKG/ControllerHelper.pm
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

package PDFAPI2PKG::ControllerHelper;

use strict;
use warnings;
use utf8;
use v5.10;

use Exporter "import";

# Helper constants.
use constant EXIT_FAILURE    =>    0; #    Failing exit status.
use constant EXIT_SUCCESS    =>    1; # Successful exit status.
use constant COLON_SPACE_SEP => ": ";
use constant CURRENT_DIR     => "./";
use constant EMPTY_STRING    =>   "";
use constant NEW_LINE        => "\n";
use constant PIPE            =>  "|";
use constant PLUS            =>  "+";
use constant MINUS           =>  "-";

# Common error messages.
use constant ERROR_PREFIX        => "Error";
use constant ERROR_NO_DB_CONNECT => "Could not connect to the database.";
use constant ERROR_NO_DATA       => "No data found.";
use constant ERROR_NO_REPORT_GEN => "Could not generate the report.";

## Props to export.
our @EXPORT_OK = (
    "EXIT_FAILURE",
    "EXIT_SUCCESS",
    "COLON_SPACE_SEP",
    "CURRENT_DIR",
    "EMPTY_STRING",
    "NEW_LINE",
    "PIPE",
    "PLUS",
    "MINUS",
    "ERROR_PREFIX",
    "ERROR_NO_DB_CONNECT",
    "ERROR_NO_DATA",
    "ERROR_NO_REPORT_GEN",
);

1;

# vim:set nu:et:ts=4:sw=4:

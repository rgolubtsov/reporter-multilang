#
# reporter-cli/sql-pdf/perl/src/ReporterPrimary/ControllerHelper.pm
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

package ReporterPrimary::ControllerHelper;

use strict;
use warnings;
use utf8;
use v5.10;

use Exporter "import";

# Helper constants.
use constant _EXIT_FAILURE    =>    0; #    Failing exit status.
use constant _EXIT_SUCCESS    =>    1; # Successful exit status.
use constant _COLON_SPACE_SEP => ": ";
use constant _CURRENT_DIR     => "./";
use constant _SLASH           =>  "/";
use constant _EMPTY_STRING    =>   "";
use constant _NEW_LINE        => "\n";

# Common error messages.
use constant _ERROR_PREFIX        => "Error";
use constant _ERROR_NO_DB_CONNECT => "Could not connect to the database.";
use constant _ERROR_NO_DATA       => "No data found.";
use constant _ERROR_NO_REPORT_GEN => "Could not generate the report.";

## Props to export.
our @EXPORT_OK = (
    "_EXIT_FAILURE",
    "_EXIT_SUCCESS",
    "_COLON_SPACE_SEP",
    "_CURRENT_DIR",
    "_SLASH",
    "_EMPTY_STRING",
    "_NEW_LINE",
# -----------------------------------------------------------------------------
    "_ERROR_PREFIX",
    "_ERROR_NO_DB_CONNECT",
    "_ERROR_NO_DATA",
    "_ERROR_NO_REPORT_GEN",
);

1;

# vim:set nu:et:ts=4:sw=4:

#
# reporter-core/sql-pdf/perl/src/PDFAPI2PKG/ReporterController.pm
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

package PDFAPI2PKG::ReporterController;

use strict;
use warnings;
use utf8;
use v5.10;

use PDFAPI2PKG::ControllerHelper
    "EXIT_FAILURE",
    "EXIT_SUCCESS",
    "COLON_SPACE_SEP",
    "CURRENT_DIR",
    "EMPTY_STRING",
    "NEW_LINE",
    "ERROR_PREFIX",
    "ERROR_NO_DATA";

use PDFAPI2PKG::ReporterModel;

## Constant: The PDF basic measurement unit -- PostScript point.
use constant PT =>   1;

## Constant: The one inch       (in PDF measurement terms).
use constant IN => ( 1   / 72);

## Constant: The one millimeter (in PDF measurement terms).
use constant MM => (25.4 / 72);

# TODO: ...:-).

## Default constructor.
sub new {
    my $class = shift();
    my $self  = [];

    bless($self, $class);

    # FIXME: Move this instantiation to the action method.
    # Instantiating the model component.
    my $model = PDFAPI2PKG::ReporterModel->new();

    return $self;
}

1;

# vim:set nu:et:ts=4:sw=4:

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

use Text::TabularDisplay;

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

##
# Constant: The start date to retrieve data set.
#    FIXME: Move to cli args.
#
use constant FROM => "2016-06-01";

##
# Constant: The end   date to retrieve data set.
#    FIXME: Move to cli args.
#
use constant TO   => "2016-12-01";

##
# Constant: The PDF report filename.
#    FIXME: Move to cli args.
#
use constant PDF_REPORT_FILENAME => "packages.pdf";

##
# Constant: The number of pages generated in a PDF report.
#    FIXME: Move to cli args.
#
use constant MAX_PAGES => 20;
#use constant MAX_PAGES => 200;

## Constant: The PDF basic measurement unit -- PostScript point.
use constant PT =>   1;

## Constant: The one inch       (in PDF measurement terms).
use constant IN => ( 1   / 72);

## Constant: The one millimeter (in PDF measurement terms).
use constant MM => (25.4 / 72);

# Draws the PDF report page body (data).
sub _page_body_draw {
    my ($report, $hdr_set, $row_set) = @_;

    my $ret = EXIT_SUCCESS;

    # TODO: ...:-).

    return $ret;
}

##
# Generates the PDF report.
#
# @param {Object} dbh - The database handle object.
#
# @returns {Number} The exit code indicating the status
#                   of generating the PDF report.
#
sub pdf_report_generate {
    my  $self = shift();
    my ($dbh) = @_;

    my $ret = EXIT_SUCCESS;

    # Instantiating the model component.
    my $model = PDFAPI2PKG::ReporterModel->new();

    # Retrieving a list of all data items stored in the database.
    my ($hdr_set, $row_set) = $model->get_all_data_items($dbh);

    # Retrieving a list of data items for a given date period.
#    my ($hdr_set, $row_set) = $model->get_data_items_by_date(FROM, TO, $dbh);

    # In case of getting an empty result set, informing the user.
    if (!(@{$row_set})) {
        $ret = EXIT_FAILURE;

        say(__PACKAGE__ . COLON_SPACE_SEP . ERROR_PREFIX
                        . COLON_SPACE_SEP . ERROR_NO_DATA);

        return $ret;
    }

    # -------------------------------------------------------------------------
    # --- Debug output - Begin ------------------------------------------------
    # -------------------------------------------------------------------------
    my $dbg_output = Text::TabularDisplay->new(@$hdr_set);

    $dbg_output->populate($row_set);

    say($dbg_output->render());

    say(@{$row_set} . " rows in set" . NEW_LINE);
    # -------------------------------------------------------------------------
    # --- Debug output - End --------------------------------------------------
    # -------------------------------------------------------------------------

    return $ret;
}

## Default constructor.
sub new {
    my $class = shift();
    my $self  = [];

    bless($self, $class);

    return $self;
}

1;

# vim:set nu:et:ts=4:sw=4:

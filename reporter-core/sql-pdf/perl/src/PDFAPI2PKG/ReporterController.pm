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
use PDF::API2;
use Try::Tiny;

use PDFAPI2PKG::ControllerHelper
    "EXIT_FAILURE",
    "EXIT_SUCCESS",
    "COLON_SPACE_SEP",
    "CURRENT_DIR",
    "EMPTY_STRING",
    "NEW_LINE",
    "ERROR_PREFIX",
    "ERROR_NO_DATA",
    "ERROR_NO_REPORT_GEN";

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

    # TODO: Bring out all string literals into constant declarations.

    # Instantiating the model component.
    my $model = PDFAPI2PKG::ReporterModel->new();

    # Retrieving a list of all data items stored in the database.
#   my ($hdr_set, $row_set) = $model->get_all_data_items($dbh);

    # Retrieving a list of data items for a given date period.
    my ($hdr_set, $row_set) = $model->get_data_items_by_date(FROM, TO, $dbh);

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

    sleep(1); # <== Waiting one second... just for fun... :-)... Please! -- OK.

    # -------------------------------------------------------------------------
    # --- Generating the PDF report - Begin -----------------------------------
    # -------------------------------------------------------------------------
    my $report = PDF::API2->new(-file => CURRENT_DIR . PDF_REPORT_FILENAME);

    # --- Page body (data) x MAX_PAGES ----------------------------------------
    for (my $i = 0; $i < MAX_PAGES; $i++) {
        $ret = _page_body_draw($report, $hdr_set, $row_set);

        if (!$ret) {
            say(__PACKAGE__ . COLON_SPACE_SEP . ERROR_PREFIX
                            . COLON_SPACE_SEP . ERROR_NO_REPORT_GEN);

            return $ret;
        }
    }

    # Trying to save the report.
    try {
        $report->save();
    } catch {
        $ret = EXIT_FAILURE;

        say(__PACKAGE__ . COLON_SPACE_SEP . ERROR_PREFIX
                        . COLON_SPACE_SEP . $_);

        return $ret;
    };
    # -------------------------------------------------------------------------
    # --- Generating the PDF report - End -------------------------------------
    # -------------------------------------------------------------------------

    return $ret;
}

# Draws the PDF report page body (data).
sub _page_body_draw {
    my ($report, $hdr_set, $row_set) = @_;

    my $ret = EXIT_SUCCESS;

    # TODO: Bring out all string literals into constant declarations.

    my %table_headers;

    # --- Page boxes ----------------------------------------------------------

    my $page = $report->page();

#   $page->mediabox("A4"); # <== 210 x 297 mm.
    $page->mediabox((210 / MM), (297 / MM)                        );
#   $page->bleedbox(  (5 / MM),   (5 / MM), (205 / MM), (292 / MM));
    $page->cropbox ( (10 / MM),  (10 / MM), (200 / MM), (287 / MM));
#   $page->artbox  ( (15 / MM),  (15 / MM), (195 / MM), (282 / MM));

    # --- Border --------------------------------------------------------------

    my $border = $page->gfx();

    $border->strokecolor("#224488"); # <== Rainy night.

    $border->linewidth(2);

    $border->rect((16 / MM), (19 / MM), (178 / MM), (259 / MM));

    $border->stroke();

    # --- Headers bar ---------------------------------------------------------

    my $hdr_bar = $page->gfx();

    $hdr_bar->fillcolor("#224488"); # <== Rainy night.

    $hdr_bar->rect((17 / MM), (267 / MM), (176 / MM), (10 / MM));

    $hdr_bar->fill();

    # --- Headers txt ---------------------------------------------------------

    my $hdr_txt = $page->text();

    my $hdr_font = $report->corefont("Helvetica-Bold");

    $hdr_txt->font($hdr_font, (16 / PT));

    $hdr_txt->fillcolor("#ffffff"); # <== White.

    $table_headers{$hdr_set->[0]} = "Arch";
    $table_headers{$hdr_set->[1]} = "Repo";
    $table_headers{$hdr_set->[2]} = "Name";
    $table_headers{$hdr_set->[3]} = "Version";
    $table_headers{$hdr_set->[4]} = "Last Updated";
    $table_headers{$hdr_set->[5]} = "Flag Date";

    my $x = 0;

    # Printing table headers.
    for (my $i = 0; $i < @$hdr_set; $i++) {
             if ($i == 1) {
            $x =  17;
        } elsif ($i == 2) {
            $x =  40;
        } elsif ($i == 3) {
            $x =  78;
        } elsif ($i == 4) {
            $x = 107;
        } elsif ($i == 5) {
            $x = 146;
        } else { # <== Includes ($i == 0).
            $x =   0;
        }

        $hdr_txt->translate(((20 + $x) / MM), (270 / MM));

        $hdr_txt->text($table_headers{$hdr_set->[$i]});
    }

    # --- Table rows ----------------------------------------------------------

    my $row_bar = $page->gfx();

    my $row_txt = $page->text();

    my $row_font = $report->corefont("Helvetica");

    $row_txt->font($row_font, (11 / PT));

    $row_txt->fillcolor("#000000"); # <== Black.

    $row_txt->translate((20 / MM), (262 / MM));

    my $y = 0;

    # Printing table rows.
#   for (my $i = 0; $i < @$row_set; $i++) {
    for (my $i = 0; $i <        40; $i++) {
        if ($i & 1) {
            $row_bar->fillcolor("#dddddd"); # <== Rainy day.
            $row_bar->rect((17 / MM), ((260 - $y) / MM), (176 / MM), (6 / MM));
            $row_bar->fill();
        }

        for (my $j = 0; $j < @$hdr_set; $j++) {
                 if ($j == 1) {
                $x =  17;
            } elsif ($j == 2) {
                $x =  40;
            } elsif ($j == 3) {
                $x =  78;
            } elsif ($j == 4) {
                $x = 123;
            } elsif ($j == 5) {
                $x = 148;
            } else { # <== Includes ($j == 0).
                $x =   0;
            }

            $row_txt->translate(((20 + $x) / MM), ((262 - $y) / MM));

            if (defined($row_set->[$i][$j])) {
                $row_txt->text($row_set->[$i][$j]);
            } else {
                $row_txt->text(EMPTY_STRING);
            }
        }

        $y += 6;
    }

    # --- Footer bar ----------------------------------------------------------

    my $xdr_bar = $page->gfx();

    $xdr_bar->fillcolor("#aaaaaa"); # <== Very light cobalt.

    $xdr_bar->rect((17 / MM), (20 / MM), (176 / MM), (6 / MM));

    $xdr_bar->fill();

    # --- Footer txt ----------------------------------------------------------

    my $xdr_txt = $page->text();

    my $xdr_font = $report->corefont("Times-Bold");

    $xdr_txt->font($xdr_font, (12 / PT));

    $xdr_txt->fillcolor("#eeeeee"); # <== Yet not white.

    $xdr_txt->translate((20 / MM), (22 / MM));

    $xdr_txt->text(@{$row_set} . " rows in set" . "  (40 rows shown)");

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

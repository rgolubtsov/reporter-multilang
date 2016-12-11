#
# reporter-core/sql-pdf/perl/src/PDFAPI2PKG/ReporterModel.pm
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

package PDFAPI2PKG::ReporterModel;

use strict;
use warnings;
use utf8;
use v5.10;

use PDFAPI2PKG::ControllerHelper
    "COLON_SPACE_SEP";

##
# Retrieves a list of all data items currently registered.
#
# @param   {Object} dbh   - TODO: Provide description.
#
# @returns {Object, Object} TODO: Provide description.
#
sub get_all_data_items {
    my  $self = shift();
    my ($dbh) = @_;

    my $sql_select = "select"
            . " attr_x0,"
            . " attr_x1,"
            . " name,"
            . " attr_x2,"
            . " description,"
            . " attr_x3,"
            . " attr_x4"
        . " from"
            . " data_items"
        . " order by"
            . " name,"
            . " attr_x3";

    # -------------------------------------------------------------------------
    # --- Debug output - Begin ------------------------------------------------
    # -------------------------------------------------------------------------
    say(__PACKAGE__ . COLON_SPACE_SEP . $sql_select);
    # -------------------------------------------------------------------------
    # --- Debug output - End --------------------------------------------------
    # -------------------------------------------------------------------------

    # Preparing the SQL statement.
    my $sth = $dbh->prepare($sql_select);

    $sth->execute();

    # Retrieving the result set metadata -- table headers.
    my $hdr_set = $sth->{NAME};

    # The result set. Finally it will be a quasi-two-dimensional array.
    my @row_set; # <== Declare it as an initially empty.

    my $i = 0;

    # Retrieving and processing the result set -- table rows.
    while (my @row_ary = $sth->fetchrow_array()) {
        $row_set[$i] = [@row_ary];

        $i++;
    }

    return (\@$hdr_set, \@row_set);
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

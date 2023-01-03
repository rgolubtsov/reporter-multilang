#
# reporter-cli/sql-pdf/perl/src/ReporterPrimary/ReporterModel.pm
# =============================================================================
# Reporter Multilang. Version 0.5.9
# =============================================================================
# A tool to generate human-readable reports based on data from various sources
# with the focus on its implementation using a series of programming languages.
# =============================================================================
# Written by Radislav (Radicchio) Golubtsov, 2016-2023
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

package ReporterPrimary::ReporterModel;

use strict;
use warnings;
use utf8;
use v5.10;

##
# Retrieves a list of all data items stored in the database.
#
# @param {Object} dbh - The database handle object.
#
# @returns {Object, Object} References to two arrays containing
#                           table headers and rows.
#
sub get_all_data_items {
    my  $self = shift();
    my ($dbh) = @_;

    my $sql_select = "select"
            . "      x0.name as arch,"
            . "      x1.name as repo,"
            . "   items.name,"
            . " attr_x2      as version,"
#           . "   items.description,"
            . " attr_x3      as last_updated,"
            . " attr_x4      as flag_date"
        . " from"
            . " data_items items,"
            . "   attr_x0s x0,"
            . "   attr_x1s x1"
        . " where"
            . " (attr_x0_id  = x0.id) and"
            . " (attr_x1_id  = x1.id)" # and"
#           . " (attr_x4 is not null)"
        . " order by"
            . " items.name,"
            . "       arch";

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

##
# Retrieves a list of data items for a given date period.
#
# @param {String} from - The start date to retrieve data set.
# @param {String} to   - The end   date to retrieve data set.
# @param {Object} dbh  - The database handle object.
#
# @returns {Object, Object} References to two arrays containing
#                           table headers and rows.
#
sub get_data_items_by_date {
    my  $self = shift();
    my ($from, $to, $dbh) = @_;

    my $sql_select = "select"
            . "      x0.name as arch,"
            . "      x1.name as repo,"
            . "   items.name,"
            . " attr_x2      as version,"
#           . "   items.description,"
            . " attr_x3      as last_updated,"
            . " attr_x4      as flag_date"
        . " from"
            . " data_items items,"
            . "   attr_x0s x0,"
            . "   attr_x1s x1"
        . " where"
            . " (attr_x0_id = x0.id) and"
            . " (attr_x1_id = x1.id) and"
# -----------------------------------------------------------------------------
#           . " (attr_x3   >=     ?) and"
#           . " (attr_x3   <=     ?)"
# -----------------------------------------------------------------------------
            . " (attr_x3 between ? and ?)"
# -----------------------------------------------------------------------------
        . " order by"
            . " items.name,"
            . "       arch";

    # Preparing the SQL statement.
    my $sth = $dbh->prepare($sql_select);

    $sth->execute($from, $to);

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

# vim:set nu et ts=4 sw=4:

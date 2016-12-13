#
# reporter-core/sql-pdf/perl/src/PDFAPI2PKG.pm
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

package PDFAPI2PKG;

use strict;
use warnings;
use utf8;
use v5.10;

use Try::Tiny;
use DBI;

use PDFAPI2PKG::ControllerHelper
    "EXIT_FAILURE",
    "EXIT_SUCCESS",
    "COLON_SPACE_SEP",
    "ERROR_PREFIX",
    "ERROR_NO_DB_CONNECT";

use PDFAPI2PKG::ReporterController;

##
# Constant: The database name.
#    FIXME: Move to cli args.
#
use constant DATABASE => "reporter_multilang";

##
# Constant: The database server name.
#    FIXME: Move to cli args.
#
use constant HOSTNAME => "10.0.2.100";
#use constant HOSTNAME => "localhost";

##
# Constant: The data source name (DSN) -- the logical database identifier.
#    FIXME: Move to the startup() method.
#
use constant DSN => "DBI:mysql:database=" . DATABASE . ";host=" . HOSTNAME;

##
# Constant: The username to connect to the database.
#    FIXME: Move to cli args.
#
use constant USERNAME => "reporter";

##
# Constant: The password to connect to the database.
#    FIXME: Move to cli args.
#
use constant PASSWORD => "retroper12345678";

## Constant: The "RaiseError" database connectivity attribute.
use constant RAISE_ERROR_DBI_ATTR => 1;

## Constant: The "AutoCommit" database connectivity attribute.
use constant AUTO_COMMIT_DBI_ATTR => 0;

##
# Starts up the app.
#
# @param {String[]} args - The array of command-line arguments.
#
# @returns {Number} The exit code indicating the app overall execution status.
#
sub startup {
    my  $self  = shift();
    my ($args) = @_;

    my $ret = EXIT_SUCCESS;

    my $dbh;

    my %attr = (
        RaiseError => RAISE_ERROR_DBI_ATTR,
        AutoCommit => AUTO_COMMIT_DBI_ATTR,
    );

    # Trying to connect to the database.
    try {
        $dbh = DBI->connect(DSN, USERNAME, PASSWORD, \%attr);
    } catch {
        $ret = EXIT_FAILURE;

        say(__PACKAGE__ . COLON_SPACE_SEP . ERROR_PREFIX
                        . COLON_SPACE_SEP . $_);

        return $ret;
    };

    # Instantiating the controller component.
    my $ctrl = PDFAPI2PKG::ReporterController->new();

    if ($dbh) {
        # Generating the PDF report.
        $ret = $ctrl->pdf_report_generate($dbh);

        # Disconnecting from the database.
        $dbh->disconnect();
    } else {
        $ret = EXIT_FAILURE;

        say(__PACKAGE__ . COLON_SPACE_SEP . ERROR_PREFIX
                        . COLON_SPACE_SEP . ERROR_NO_DB_CONNECT);

        return $ret;
    }

    # -------------------------------------------------------------------------
    # --- Debug output - Begin ------------------------------------------------
    # -------------------------------------------------------------------------
#    $self = 2;

#         if ($args->[0] eq "mysql") {
#        $self = 0;
#    } elsif ($args->[0] eq "pgsql") {
#        $self = 1;
#    } else {
#        $args->[0] = "--";
#    }

#    say("$self $args->[0] $ctrl");
    # -------------------------------------------------------------------------
    # --- Debug output - End --------------------------------------------------
    # -------------------------------------------------------------------------

    return $ret;
}

1;

# vim:set nu:et:ts=4:sw=4:

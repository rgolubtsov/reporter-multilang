#
# reporter-cli/sql-csv/perl/src/ReporterPrimary.pm
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

# TODO: Perform architectural investigations and decide
#       what has to be rewritten in order not to duplicate
#       the code for generating PDF reports, but in contrary,
#       to reuse it wherever possible.

package ReporterPrimary;

use strict;
use warnings;
use utf8;
use v5.10;

use Try::Tiny;
use DBI;

use ReporterPrimary::ControllerHelper
    "_EXIT_FAILURE",
    "_EXIT_SUCCESS",
    "_COLON_SPACE_SEP",
    "_SLASH",
    "_EMPTY_STRING",
# -----------------------------------------------------------------------------
    "_ERROR_PREFIX",
    "_ERROR_NO_DB_CONNECT";

use ReporterPrimary::ReporterController;

##
# Constant: The SQLite database location.
#     TODO: Move to cli args.
#
use constant SQLITE_DB_DIR => "data";

##
# Constant: The database name.
#     TODO: Move to cli args.
#
use constant DATABASE => "reporter_multilang";

##
# Constant: The database server name.
#     TODO: Move to cli args.
#
use constant HOSTNAME => "10.0.2.100";
#use constant HOSTNAME => "localhost";

##
# Constant: The data source name (DSN) for MySQL database --
#           the logical database identifier.
#     TODO: Move to the startup() method.
#
use constant MY_DSN => "dbi:mysql:database=" . DATABASE . ";host=" . HOSTNAME;

##
# Constant: The data source name (DSN) for PostgreSQL database --
#           the logical database identifier.
#     TODO: Move to the startup() method.
#
use constant PG_DSN => "dbi:Pg:database=" . DATABASE . ";host=" . HOSTNAME;

##
# Constant: The data source name (DSN) prefix for SQLite database --
#           the logical database identifier prefix.
#     TODO: Move to the startup() method.
#
use constant SL_DSN_PREFIX => "dbi:SQLite:database=";

##
# Constant: The username to connect to the database.
#     TODO: Move to cli args.
#
use constant USERNAME => "reporter";

##
# Constant: The password to connect to the database.
#     TODO: Move to cli args.
#
use constant PASSWORD => "retroper12345678";

## Constant: The "RaiseError" database connectivity attribute.
use constant RAISE_ERROR_DBI_ATTR => 1;

## Constant: The "AutoCommit" database connectivity attribute.
use constant AUTO_COMMIT_DBI_ATTR => 0;

# Database switches. They indicate which database to connect to.
use constant _MY_CONNECT => "mysql";
use constant _PG_CONNECT => "postgres";
use constant _SL_CONNECT => "sqlite";

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

    my $ret = _EXIT_SUCCESS;

    my $db_switch = $args->[0];

    my $dbh;

    my %attr = (
        RaiseError => RAISE_ERROR_DBI_ATTR,
        AutoCommit => AUTO_COMMIT_DBI_ATTR,
    );

    # Trying to connect to the database.
    try {
             if ($db_switch eq _MY_CONNECT) {
            $dbh = DBI->connect(MY_DSN, USERNAME, PASSWORD, \%attr);
        } elsif ($db_switch eq _PG_CONNECT) {
            $dbh = DBI->connect(PG_DSN, USERNAME, PASSWORD, \%attr);
        } elsif ($db_switch eq _SL_CONNECT) {
            $dbh = DBI->connect(SL_DSN_PREFIX . _get_sqlite_db_path(__FILE__),
                                                _EMPTY_STRING, _EMPTY_STRING);
        }
    } catch {
        $ret = _EXIT_FAILURE;

        say(__PACKAGE__ . _COLON_SPACE_SEP . _ERROR_PREFIX
                        . _COLON_SPACE_SEP . $_);

        return $ret;
    };

    if ($dbh) {
        # Instantiating the controller class.
        my $ctrl = ReporterPrimary::ReporterController->new();

        # Generating the CSV report.
        $ret = $ctrl->csv_report_generate($dbh);

        # Disconnecting from the database.
        $dbh->disconnect();
    } else {
        $ret = _EXIT_FAILURE;

        say(__PACKAGE__ . _COLON_SPACE_SEP . _ERROR_PREFIX
                        . _COLON_SPACE_SEP . _ERROR_NO_DB_CONNECT);

        return $ret;
    }

    return $ret;
}

# Helper function.
# Returns the SQLite database path, relative to this module location.
sub _get_sqlite_db_path {
    my ($module) = @_;

    my @module_path    = split(/\//, $module);
    my $module_name    = pop(@module_path);
    my $sqlite_db_path = join(_SLASH, @module_path,
                                      SQLITE_DB_DIR . _SLASH . DATABASE);

    return $sqlite_db_path;
}

1;

# vim:set nu:et:ts=4:sw=4:

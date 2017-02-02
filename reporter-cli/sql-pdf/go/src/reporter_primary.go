/*
 * reporter-cli/sql-pdf/go/src/reporter_primary.go
 * ============================================================================
 * Reporter Multilang. Version 0.1
 * ============================================================================
 * A tool to generate human-readable reports based on data from various sources
 * with the focus on its implementation using a series of programming languages
 * ============================================================================
 * Written by Radislav (Radicchio) Golubtsov, 2016-2017
 *
 * This is free and unencumbered software released into the public domain.
 *
 * Anyone is free to copy, modify, publish, use, compile, sell, or
 * distribute this software, either in source code form or as a compiled
 * binary, for any purpose, commercial or non-commercial, and by any
 * means.
 *
 * (See the LICENSE file at the top of the source tree.)
 */

package main

import "os"

/** The main class of the application. */
type ReporterPrimary struct {}

/**
 * Starts up the app.
 *
 * @param args The array of command-line arguments.
 *
 * @return The exit code indicating the app overall execution status.
 */
func (ReporterPrimary) startup(args []string) int {
    var ret int = 0

    if args[0] == "" {
        ret = 1
    }

    return ret
}

// The application entry point.
func main(/*args []string*/) {
    var args_len uint = uint(len(os.Args) - 1)

    var args [1]string

    if args_len > 0 {
        args[0] = os.Args[1]
    } else {
        args[0] = ""
    }

    // Instantiating the main class.
    reporter := new(ReporterPrimary)

    // Starting up the app.
    var ret int = reporter.startup(args[:])

    os.Exit(ret)
}

// vim:set nu:et:ts=4:sw=4:

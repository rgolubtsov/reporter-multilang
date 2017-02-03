#
# reporter-cli/sql-pdf/go/src/Makefile
# =============================================================================
# Reporter Multilang. Version 0.1
# =============================================================================
# A tool to generate human-readable reports based on data from various sources
# with the focus on its implementation using a series of programming languages.
#
# (See outer Makefile to understand how this one is processed.)
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

PRJ_PREFIX = reporter-
PRJ_SUFFIX = -pdf
EXEC       = $(PRJ_PREFIX)sql$(PRJ_SUFFIX)
DEPS       = $(EXEC).o
SRCS       = reporter_primary.go    \
             reporter_controller.go \
             reporter_model.go      \
             controller_helper.go
BIN_DIR    = ../bin
OBJ_DIR    = ../obj

# Specify flags and other vars here.
GO            = go tool
GO_COMP_FLAGS = compile -complete -o
GO_LINK_FLAGS = link -s -w -o

MV      = mv
MVFLAGS = -v

# Making the target.
$(DEPS): $(SRCS)
	$(GO) $(GO_COMP_FLAGS) $(DEPS) $(SRCS)

$(EXEC): $(DEPS)
	$(GO) $(GO_LINK_FLAGS) $(EXEC) $(DEPS)

.PHONY: all clean

all: $(EXEC)
	$(MV) $(MVFLAGS) $(EXEC) $(BIN_DIR)
	$(MV) $(MVFLAGS) $(DEPS) $(OBJ_DIR)

clean:
	$(RM) $(EXEC) $(DEPS)

# vim:set nu:et:ts=4:sw=4:

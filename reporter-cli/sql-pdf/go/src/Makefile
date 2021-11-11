#
# reporter-cli/sql-pdf/go/src/Makefile
# =============================================================================
# Reporter Multilang. Version 0.5.9
# =============================================================================
# A tool to generate human-readable reports based on data from various sources
# with the focus on its implementation using a series of programming languages.
#
# (See outer Makefile to understand how this one is processed.)
# =============================================================================
# Written by Radislav (Radicchio) Golubtsov, 2016-2021
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
PKG_DIR    = ../pkg
BIN_DIR    = ../bin
OBJ_DIR    = ../obj

# Specify flags and other vars here.
EXPORT        = export
GO_ENV        = go env
GREP          = grep
SED           = sed
SEDFLAGS      = -e
SEDREGEX      = 's/\"//g'

EV_GOOS       = GOOS
EV_GOARCH     = GOARCH
EXP_EV_GOOS   = $(EXPORT) `$(GO_ENV) | $(GREP) $(EV_GOOS)   | $(SED) $(SEDFLAGS) $(SEDREGEX)`
EXP_EV_GOARCH = $(EXPORT) `$(GO_ENV) | $(GREP) $(EV_GOARCH) | $(SED) $(SEDFLAGS) $(SEDREGEX)`

GO_TOOL       = go tool
GO_COMP_FLAGS = compile -complete -o $(DEPS) -I $(PKG_DIR)
GO_LINK_FLAGS = link -s -w        -o $(EXEC) -L $(PKG_DIR)

MV            = mv
MVFLAGS       = -v

# Making the target.
$(DEPS): $(SRCS)
	$(EXP_EV_GOOS); \
	$(EXP_EV_GOARCH); \
	$(GO_TOOL) $(GO_COMP_FLAGS)/$${$(EV_GOOS)}_$${$(EV_GOARCH)} $(SRCS)

$(EXEC): $(DEPS)
	$(EXP_EV_GOOS); \
	$(EXP_EV_GOARCH); \
	$(GO_TOOL) $(GO_LINK_FLAGS)/$${$(EV_GOOS)}_$${$(EV_GOARCH)} $(DEPS)

.PHONY: all clean

all: $(EXEC)
	$(MV) $(MVFLAGS) $(EXEC) $(BIN_DIR)
	$(MV) $(MVFLAGS) $(DEPS) $(OBJ_DIR)

clean:
	$(RM) $(EXEC) $(DEPS)

# vim:set nu ts=4 sw=4:

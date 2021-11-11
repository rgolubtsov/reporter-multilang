#
# reporter-cli/sql-pdf/vala/Makefile
# =============================================================================
# Reporter Multilang. Version 0.5.9
# =============================================================================
# A tool to generate human-readable reports based on data from various sources
# with the focus on its implementation using a series of programming languages.
#
# (See inner Makefile to find out actual build rules.)
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

BIN_DIR      = bin
LIB_DIR      = lib
SRC_DIR      = src
DAT_DIR      = $(LIB_DIR)/data
SQLITE_DBASE = reporter_multilang.xz
ALL_TARGET   = all

# Specify flags and other vars here.
MKDIR      = mkdir
CP         = cp
CPFLAGS    = -vR
UNXZ       = unxz
UNXZFLAGS  = -v

# Using here this user-defined var because "The options ‘-C’, ‘-f’, ‘-o’,
# and ‘-W’ are not put into MAKEFLAGS; these options are not passed down."
# -- from the GNU Make Manual. I.e. use of MAKEFLAGS cannot be applicable
# in this case.
MAKE_FLAGS = -C

RMFLAGS    = -vR

# Making the target.
$(BIN_DIR) $(LIB_DIR):
	if [ ! -d "$(BIN_DIR)" ]; then \
		$(MKDIR) $(BIN_DIR); \
		if [ ! -d "$(LIB_DIR)" ]; then \
			$(MKDIR) $(LIB_DIR); \
		fi; \
		if [ -d "$(LIB_DIR)" ]; then \
			$(MKDIR) $(DAT_DIR); \
		fi; \
		$(CP) $(CPFLAGS) ../../../data/$(SQLITE_DBASE) $(DAT_DIR); \
		$(UNXZ) $(UNXZFLAGS) $(DAT_DIR)/$(SQLITE_DBASE); \
		$(MAKE) $(MAKE_FLAGS)$(SRC_DIR) $(ALL_TARGET); \
	fi

.PHONY: all clean

all: $(BIN_DIR) $(LIB_DIR)

clean:
	$(RM) $(RMFLAGS) $(BIN_DIR) $(LIB_DIR)

# vim:set nu ts=4 sw=4:

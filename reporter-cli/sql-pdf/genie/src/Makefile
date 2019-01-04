#
# reporter-cli/sql-pdf/genie/src/Makefile
# =============================================================================
# Reporter Multilang. Version 0.1
# =============================================================================
# A tool to generate human-readable reports based on data from various sources
# with the focus on its implementation using a series of programming languages.
#
# (See outer Makefile to understand how this one is processed.)
# =============================================================================
# Written by Radislav (Radicchio) Golubtsov, 2016-2019
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

PRJ_PREFIX      = reporter-
PRJ_SUFFIX      = -pdf
EXEC1           = $(PRJ_PREFIX)mysql$(PRJ_SUFFIX)
EXEC2           = $(PRJ_PREFIX)postgres$(PRJ_SUFFIX)
EXEC3           = $(PRJ_PREFIX)sqlite$(PRJ_SUFFIX)
SRCES           = $(PRIMA) \
                  $(CNTRL) \
                  $(MODEL) \
                  $(AUXER)
PRIMA           = reporter_primary.gs
CNTRL           = reporter_controller.gs
MODEL           = reporter_model.gs
AUXER           = controller_helper.vala
HDRS_DIR_PREFIX = /usr/include/
PG_CLIENT_H_DIR = postgresql/
PG_CLIENT_HEADR = libpq-fe.h
BIN_DIR         = ../bin

# Specify flags and other vars here.
VC      = valac
VCFLAGS = --target-glib=2.40 -X -s -X -O3 --pkg=posix --pkg=pangocairo

SUDO    = sudo
LN      = ln
LNFLAGS = -sfv
MV      = mv
MVFLAGS = -v

# Making the 1st target (mysql-pdf).
$(EXEC1): VCFLAGS += --pkg=mysql -X -lmysqlclient -D MYSQL -o
$(EXEC1): $(SRCES)
	$(VC) $(VCFLAGS) $(EXEC1) $(SRCES)

# Making the 2nd target (postgres-pdf).
$(EXEC2): VCFLAGS += --pkg=libpq -D POSTGRES -o
# $(EXEC2): VCFLAGS += --pkg=libpq -X `pkg-config --libs libpq` -D POSTGRES -o
$(EXEC2): $(SRCES)
	if [ ! -e "$(HDRS_DIR_PREFIX)$(PG_CLIENT_H_DIR)$(PG_CLIENT_HEADR)" ]; then \
		$(SUDO) $(LN) $(LNFLAGS) $(HDRS_DIR_PREFIX)$(PG_CLIENT_HEADR) \
			$(HDRS_DIR_PREFIX)$(PG_CLIENT_H_DIR)$(PG_CLIENT_HEADR); \
	fi
	$(VC) $(VCFLAGS) $(EXEC2) $(SRCES)

# Making the 3rd target (sqlite-pdf).
$(EXEC3): VCFLAGS += --pkg=sqlite3 -D SQLITE -o
# $(EXEC3): VCFLAGS += --pkg=sqlite3 -X `pkg-config --libs sqlite3` -D SQLITE -o
$(EXEC3): $(SRCES)
	$(VC) $(VCFLAGS) $(EXEC3) $(SRCES)

.PHONY: mysql-pdf postgres-pdf sqlite-pdf all clean

mysql-pdf   : $(EXEC1)
postgres-pdf: $(EXEC2)
sqlite-pdf  : $(EXEC3)

all: mysql-pdf postgres-pdf sqlite-pdf
	$(MV) $(MVFLAGS) $(EXEC1) $(EXEC2) $(EXEC3) $(BIN_DIR)

clean:
	$(RM) $(EXEC1) $(EXEC2) $(EXEC3)

# vim:set nu ts=4 sw=4:

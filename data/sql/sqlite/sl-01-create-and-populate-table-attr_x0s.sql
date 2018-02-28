--
-- data/sql/sl-01-create-and-populate-table-attr_x0s.sql
-- ============================================================================
-- Reporter Multilang. Version 0.1
-- ============================================================================
-- A tool to generate human-readable reports based on data from various sources
-- with the focus on its implementation using a series of programming languages
-- ============================================================================
-- Written by Radislav (Radicchio) Golubtsov, 2016
--
-- This is free and unencumbered software released into the public domain.
--
-- Anyone is free to copy, modify, publish, use, compile, sell, or
-- distribute this software, either in source code form or as a compiled
-- binary, for any purpose, commercial or non-commercial, and by any
-- means.
--
-- (See the LICENSE file at the top of the source tree.)
--

.headers on
.mode    column

.tables
.print

create table attr_x0s (id          integer   primary key autoincrement,
                       name        character varying(64) not null,
                       description character varying(1024));

.tables
.print

pragma table_info(attr_x0s);
.print

select * from attr_x0s;

insert into attr_x0s (name, description) values ('any',    'Any ==========');
insert into attr_x0s (name, description) values ('i686',   'I686 =========');
insert into attr_x0s (name, description) values ('x86_64', 'X86_64 =======');

select * from attr_x0s;

-- vim:set nu et ts=4 sw=4:

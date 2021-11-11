--
-- data/sql/my-02-create-and-populate-table-attr_x1s.sql
-- ============================================================================
-- Reporter Multilang. Version 0.5.9
-- ============================================================================
-- A tool to generate human-readable reports based on data from various sources
-- with the focus on its implementation using a series of programming languages
-- ============================================================================
-- Written by Radislav (Radicchio) Golubtsov, 2016-2021
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

show tables;

create table attr_x1s (id          serial    primary key,
                       name        character varying(64) not null,
                       description character varying(1024));

show tables;

show columns in attr_x1s;

select * from attr_x1s;

insert into attr_x1s (name, description) values ('core',  'Core ============');
insert into attr_x1s (name, description) values ('extra', 'Extra ===========');
insert into attr_x1s (name, description) values ('community',
                                                          'Community =======');
insert into attr_x1s (name, description) values ('multilib',
                                                          'Multilib ========');

select * from attr_x1s;

-- vim:set nu et ts=4 sw=4:

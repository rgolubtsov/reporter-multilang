--
-- data/sql/03-create-and-populate-table-data_items.sql
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

show tables;

create table data_items (id          serial    primary key,
                         name        character varying(64)   not null,
                         description character varying(1024) not null,
                         attr_x0_id  bigint    unsigned      not null
                             references attr_x0s(id)      on delete restrict,
                         attr_x1_id  bigint    unsigned      not null
                             references attr_x1s(id)      on delete restrict,
                         attr_x2     character varying(32)   not null,
                         attr_x3     date                    not null,
                         attr_x4     date);

show tables;

show columns in data_items;

select * from data_items;

insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('a52dec', 'A free library for decoding ATSC A/52 streams', 2, 2, '0.7.4-9', '2016-06-10');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('a52dec', 'A free library for decoding ATSC A/52 streams', 3, 2, '0.7.4-9', '2016-06-10');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('aalib', 'A portable ASCII art graphic library', 2, 2, '1.4rc5-12', '2016-05-05');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('aalib', 'A portable ASCII art graphic library', 3, 2, '1.4rc5-12', '2016-05-05');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('acl', 'Access control list utilities, libraries and headers', 2, 1, '2.2.52-3', '2016-11-11');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('acl', 'Access control list utilities, libraries and headers', 3, 1, '2.2.52-3', '2016-11-11');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('acpi', 'Client for battery, power, and thermal readings', 2, 3, '1.7-1', '2014-01-02');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('acpi', 'Client for battery, power, and thermal readings', 3, 3, '1.7-1', '2014-01-02');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('adwaita-icon-theme', 'Adwaita icon theme', 1, 2, '3.22.0-1', '2016-10-12');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('alsa-lib', 'An alternative implementation of Linux sound support', 2, 2, '1.1.2-1', '2016-08-08');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('alsa-lib', 'An alternative implementation of Linux sound support', 3, 2, '1.1.2-1', '2016-08-08');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('alsa-plugins', 'Extra alsa plugins', 2, 2, '1.1.1-1', '2016-04-06');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('alsa-plugins', 'Extra alsa plugins', 3, 2, '1.1.1-1', '2016-04-06');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('alsa-utils', 'An alternative implementation of Linux sound support', 2, 2, '1.1.2-1', '2016-08-08');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('alsa-utils', 'An alternative implementation of Linux sound support', 3, 2, '1.1.2-1', '2016-08-08');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('apr', 'The Apache Portable Runtime', 2, 2, '1.5.2-1', '2015-05-01');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('apr', 'The Apache Portable Runtime', 3, 2, '1.5.2-1', '2015-05-01');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('apr-util', 'The Apache Portable Runtime', 2, 2, '1.5.4-2', '2016-03-06');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('apr-util', 'The Apache Portable Runtime', 3, 2, '1.5.4-2', '2016-03-06');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('archlinux-keyring', 'Arch Linux PGP keyring', 1, 1, '20161201-1', '2016-12-03');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('bash', 'The GNU Bourne Again shell', 2, 1, '4.4.005-1', '2016-11-21');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('bash', 'The GNU Bourne Again shell', 3, 1, '4.4.005-1', '2016-11-21');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('bash-completion', 'Programmable completion for the bash shell', 1, 2, '2.4-1', '2016-09-07');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('curl', 'An URL retrieval utility and library', 2, 1, '7.51.0-2', '2016-12-06');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('curl', 'An URL retrieval utility and library', 3, 1, '7.51.0-2', '2016-12-06');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('dos2unix', 'Text file format converter', 2, 3, '7.3.4-1', '2016-06-01');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('dos2unix', 'Text file format converter', 3, 3, '7.3.4-1', '2016-06-01');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('gcc-fortran', 'Fortran front-end for GCC', 2, 1, '6.2.1-1', '2016-09-09');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('gcc-fortran', 'Fortran front-end for GCC', 3, 1, '6.2.1-1', '2016-09-09');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('gcc-libs-multilib', 'Runtime libraries shipped by GCC for multilib', 3, 4, '6.2.1-1', '2016-09-09');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('gcc-multilib', 'The GNU Compiler Collection - C and C++ frontends for multilib', 3, 4, '6.2.1-1', '2016-09-09');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('gcc-objc', 'Objective-C front-end for GCC', 2, 1, '6.2.1-1', '2016-09-09');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('gcc-objc', 'Objective-C front-end for GCC', 3, 1, '6.2.1-1', '2016-09-09');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('keybase', 'CLI tool for GPG with keybase.io', 2, 3, '1.0.18-1', '2016-11-02');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('keybase', 'CLI tool for GPG with keybase.io', 3, 3, '1.0.18-1', '2016-11-02');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('lib32-openssl', 'The Open Source toolkit for Secure Sockets Layer and Transport Layer Security (32-bit)', 3, 4, '1:1.0.2.j-1', '2016-09-27');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('lib32-zlib', 'Compression library implementing the deflate compression method found in gzip and PKZIP (32-bit)', 3, 4, '1.2.8-1', '2013-05-02');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('libffi', 'Portable foreign function interface library', 2, 1, '3.2.1-2', '2016-07-04');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('libffi', 'Portable foreign function interface library', 3, 1, '3.2.1-2', '2016-07-04');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('libxslt', 'XML stylesheet transformation library', 2, 2, '1.1.29+23+geb1030d-1', '2016-10-31');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('libxslt', 'XML stylesheet transformation library', 3, 2, '1.1.29+23+geb1030d-1', '2016-10-31');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3, attr_x4)
                values ('linux', 'The Linux kernel and modules', 2, 1, '4.8.13-1', '2016-12-11', '2016-12-11');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3, attr_x4)
                values ('linux', 'The Linux kernel and modules', 3, 1, '4.8.13-1', '2016-12-11', '2016-12-11');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3, attr_x4)
                values ('linux-api-headers', 'Kernel headers sanitized for use in userspace', 2, 1, '4.7-1', '2016-08-05', '2016-11-17');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3, attr_x4)
                values ('linux-api-headers', 'Kernel headers sanitized for use in userspace', 3, 1, '4.7-1', '2016-08-05', '2016-11-17');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('linux-firmware', 'Firmware files for Linux', 1, 1, '20161005.9c71af9-1', '2016-10-11');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3, attr_x4)
                values ('linux-headers', 'Header files and scripts for building modules for Linux kernel', 2, 1, '4.8.13-1', '2016-12-11', '2016-12-11');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3, attr_x4)
                values ('linux-headers', 'Header files and scripts for building modules for Linux kernel', 3, 1, '4.8.13-1', '2016-12-11', '2016-12-11');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('pacman', 'A library-based package manager with dependency support', 2, 1, '5.0.1-4', '2016-05-23');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('pacman', 'A library-based package manager with dependency support', 3, 1, '5.0.1-4', '2016-05-23');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('pacman-mirrorlist', 'Arch Linux mirror list for use by pacman', 1, 1, '20161211-1', '2016-12-11');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('pcre', 'A library that implements Perl 5-style regular expressions', 2, 1, '8.39-2', '2016-11-14');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('pcre', 'A library that implements Perl 5-style regular expressions', 3, 1, '8.39-2', '2016-11-14');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('pcre2', 'A library that implements Perl 5-style regular expressions. 2nd version', 2, 3, '10.22-2', '2016-11-14');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('pcre2', 'A library that implements Perl 5-style regular expressions. 2nd version', 3, 3, '10.22-2', '2016-11-14');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('perl', 'A highly capable, feature-rich programming language', 2, 1, '5.24.0-2', '2016-09-15');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('perl', 'A highly capable, feature-rich programming language', 3, 1, '5.24.0-2', '2016-09-15');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('perl-dbd-mysql', 'Perl/CPAN DBD::mysql module for interacting with MySQL via DBD', 2, 2, '4.041-1', '2016-12-01');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('perl-dbd-mysql', 'Perl/CPAN DBD::mysql module for interacting with MySQL via DBD', 3, 2, '4.041-1', '2016-12-01');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('perl-try-tiny', 'Minimal try/catch with proper localization of $@', 1, 2, '0.27-1', '2016-08-17');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3, attr_x4)
                values ('python', 'Next generation of the python high-level scripting language', 2, 2, '3.5.2-3', '2016-11-14', '2016-12-12');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3, attr_x4)
                values ('python', 'Next generation of the python high-level scripting language', 3, 2, '3.5.2-3', '2016-11-14', '2016-12-12');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('python-prettytable', 'A simple Python library for easily displaying tabular data', 1, 3, '0.7.2-7', '2015-10-25');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('python-pyelftools', 'Python library for analyzing ELF files and DWARF debugging information', 1, 2, '0.24-1', '2016-08-06');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('windowmaker', 'An X11 window manager with a NEXTSTEP look and feel', 2, 2, '0.95.7-1', '2015-09-02');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('windowmaker', 'An X11 window manager with a NEXTSTEP look and feel', 3, 2, '0.95.7-1', '2015-09-02');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3, attr_x4)
                values ('xorg-server', 'Xorg X server', 2, 2, '1.18.4-1', '2016-07-20', '2016-11-15');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3, attr_x4)
                values ('xorg-server', 'Xorg X server', 3, 2, '1.18.4-1', '2016-07-20', '2016-11-15');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3, attr_x4)
                values ('xorg-server-common', 'Xorg server common files', 2, 2, '1.18.4-1', '2016-07-20', '2016-11-15');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3, attr_x4)
                values ('xorg-server-common', 'Xorg server common files', 3, 2, '1.18.4-1', '2016-07-20', '2016-11-15');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('yasm', 'A rewrite of NASM to allow for multiple syntax supported (NASM, TASM, GAS, etc.)', 2, 2, '1.3.0-1', '2014-08-11');
insert into data_items (name, description, attr_x0_id, attr_x1_id, attr_x2, attr_x3)
                values ('yasm', 'A rewrite of NASM to allow for multiple syntax supported (NASM, TASM, GAS, etc.)', 3, 2, '1.3.0-1', '2014-08-11');

select items.id,
       items.name,
          x0.name as arch,
          x1.name as repo,
     attr_x2      as version,
--       items.description,
     attr_x3 as last_updated,
     attr_x4 as flag_date
 from
     data_items items,
       attr_x0s x0,
       attr_x1s x1
 where
     (attr_x0_id  = x0.id) and
     (attr_x1_id  = x1.id) and
     (attr_x4 is not null)
 order by
     items.name,
           arch;

select count(id) from data_items;

-- vim:set nu:et:ts=4:sw=4:

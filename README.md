freeipa
=======

This role is building and installing the
[FreeIPA binaries](https://www.freeipa.org/page/Main_Page) directly out of the
source code.

At the moment the role supports only for Debian and Ubuntu. But RHEL based
distributions have an better FreeIPA coverage anyway.

It's providing an easy way to patch the FreeIPA sources according to
your needs. The role is getting shipped with tested and working default values
and also with [patches for FreeIPA 4.6.4](files/patches/Debian/4.6.4).

At the moment it's not possible to use this role to install FreeIPA server
on Debian 9.4. Since the package `dogtag-pki` is not present. The FreeIPA
client instead can be installed on Debian 9.4 if you combine this role with
[timorunge.sssd](https://github.com/timorunge/ansible-sssd). For further
details please take a look at the [dependencies](#dependencies),
[example 4](#4-install-freeipa-with-timorungesssd) and
[example 5](#5-install-freeipa-with-timorungesssd-and-timorungefreeipa_client).

Tested platforms are:
* Debian
  * 9.4
    Requires
    * [timorunge.sssd](https://github.com/timorunge/ansible-sssd)
* Ubuntu
  * 18.04
  * 18.10

The role is not build for the setup or configuration of FreeIPA itself. You
can use the following Ansible roles for this:

* [timorunge.freeipa_client](https://github.com/timorunge/ansible-freeipa-client)
* [timorunge.freeipa_server](https://github.com/timorunge/ansible-freeipa-server)
* [timorunge.freeipa_server_backup](https://github.com/timorunge/ansible-freeipa-server-backup)

Requirements
------------

This role requires
[Ansible 2.6.0](https://docs.ansible.com/ansible/devel/roadmap/ROADMAP_2_6.html)
or higher in order to apply [patches](#2-apply-patches-to-the-source).

You can simply use pip to install (and define) a stable version:

```sh
pip install ansible==2.6.2
```

All platform requirements are listed in the metadata file.

Install
-------

```sh
ansible-galaxy install timorunge.freeipa
```

Role Variables
--------------

The variables that can be passed to this role. You can find a brief description
in this paragraph. For all variables, take a look at
[defaults/main.yml](defaults/main.yml).

```yaml

# FreeIPA from source:

# Version definition:
freeipa_version: 4.6.4

# Enable server builds (installs additional packages)
freeipa_enable_server: false

# Install or don't install the SSSD dependency packages. If you're using a
# 3rd party component (like timorunge.sssd) to install those packages
# ensure that those packages are installed before the execution of this role.
freeipa_3rdparty_sssd_packages: false

# Patches

# In this section you can apply custom patches to FreeIPA.
# You can find one example in the README.md.
# The default patches are stored in `vars/patches/{{ ansible_os_family }}-{{ freeipa_version }}.yml`
freeipa_patches: "{{ freeipa_default_patches }}"

# Build options

# The default build options are stored in `vars/{{ ansible_os_family }}.yml`
freeipa_build_options: "{{ freeipa_default_build_options }}"
```

Examples
--------

To keep the document lean the compile options are stripped.
You can find the FreeIPA build options in [this section](#freeipa-build-options).

### 1) Configure FreeIPA according to your needs

```yaml
- hosts: freeipa
  vars:
    freeipa_version: 4.6.4
    freeipa_enable_server: false
    freeipa_build_options:
      - "--datadir=/usr/share"
      - "--disable-rpath"
      - "--disable-silent-rules"
      ...
  roles:
    - timorunge.freeipa
```

### 2) Apply patches to the source

```yaml
- hosts: freeipa
  vars:
    freeipa_version: 4.6.4
    freeipa_enable_server: false
    freeipa_patches:
      create-sysconfig-ods:
        dest_file: ipaserver/install/opendnssecinstance.py
        patch_file: files/patches/Debian/4.6.4/create-sysconfig-ods.diff
        state: present
  roles:
    - timorunge.freeipa
```

### 3) Just install the FreeIPA client

```yaml
- hosts: freeipa-client
  vars:
    freeipa_version: 4.6.4
    freeipa_enable_server: false
    freeipa_build_options:
      - "--datadir=/usr/share"
      - "--disable-rpath"
      - "--disable-silent-rules"
      ...
  roles:
    - timorunge.freeipa
```

### 4) Install FreeIPA with timorunge.sssd

```yaml
- hosts: freeipa
  vars:
    sssd_from_sources: true
    sssd_version: 1.16.3
    sssd_config_type: none
    freeipa_version: 4.6.4
    freeipa_enable_server: false
    freeipa_3rdparty_sssd_packages: true
  roles:
    - timorunge.sssd
    - timorunge.freeipa
```

### 5) Install FreeIPA with timorunge.sssd and timorunge.freeipa_client

```yaml
- hosts: freeipa-client
  vars:
    sssd_from_sources: true
    sssd_version: 1.16.3
    sssd_config_type: none
    freeipa_version: 4.6.4
    freeipa_enable_server: false
    freeipa_3rdparty_sssd_packages: true
      ...
    freeipa_client_install_pkgs: false
    freeipa_client_domain: example.com
    freeipa_client_server: ipa.example.com
    freeipa_client_realm: EXAMPLE.COM
    freeipa_client_principal: admin
    freeipa_client_password: Passw0rd
    freeipa_client_fqdn: srv-1-eu-central-1.example.com
    freeipa_client_install_options:
      - "--domain={{ freeipa_client_domain }}"
      - "--server={{ freeipa_client_server }}"
      - "--realm={{ freeipa_client_realm }}"
      - "--principal={{ freeipa_client_principal }}"
      - "--password={{ freeipa_client_password }}"
      - '--mkhomedir'
      - "--hostname={{ freeipa_client_fqdn | default(ansible_fqdn) }}"
  roles:
    - timorunge.sssd
    - timorunge.freeipa
    - timorunge.freeipa_client
```

### 6) Install FreeIPA with timorunge.sssd and timorunge.freeipa_server

```yaml
- hosts: freeipa-server
  vars:
    sssd_from_sources: true
    sssd_version: 1.16.3
    sssd_config_type: none
    freeipa_version: 4.6.4
    freeipa_enable_server: true
    freeipa_3rdparty_sssd_packages: true
    freeipa_server_install_pkgs: false
    freeipa_server_admin_password: Passw0rd
    freeipa_server_domain: example.com
    freeipa_server_ds_password: Passw0rd
    freeipa_server_fqdn: ipa.example.com
    freeipa_server_ip: 172.20.0.2
    freeipa_server_realm: EXAMPLE.COM
  roles:
    - timorunge.sssd
    - timorunge.freeipa
    - timorunge.freeipa_server
```

FreeIPA build options
---------------------

An overview of the build options for FreeIPA (4.6.4).

```sh
`configure' configures freeipa 4.6.4 to adapt to many kinds of systems.

Usage: ./configure [OPTION]... [VAR=VALUE]...

To assign environment variables (e.g., CC, CFLAGS...), specify them as
VAR=VALUE.  See below for descriptions of some of the useful variables.

Defaults for the options are specified in brackets.

Configuration:
  -h, --help              display this help and exit
      --help=short        display options specific to this package
      --help=recursive    display the short help of all the included packages
  -V, --version           display version information and exit
  -q, --quiet, --silent   do not print `checking ...' messages
      --cache-file=FILE   cache test results in FILE [disabled]
  -C, --config-cache      alias for `--cache-file=config.cache'
  -n, --no-create         do not create output files
      --srcdir=DIR        find the sources in DIR [configure dir or `..']

Installation directories:
  --prefix=PREFIX         install architecture-independent files in PREFIX
                          [/usr/local]
  --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX
                          [PREFIX]

By default, `make install' will install all the files in
`/usr/local/bin', `/usr/local/lib' etc.  You can specify
an installation prefix other than `/usr/local' using `--prefix',
for instance `--prefix=$HOME'.

For better control, use the options below.

Fine tuning of the installation directories:
  --bindir=DIR            user executables [EPREFIX/bin]
  --sbindir=DIR           system admin executables [EPREFIX/sbin]
  --libexecdir=DIR        program executables [EPREFIX/libexec]
  --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
  --sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
  --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
  --runstatedir=DIR       modifiable per-process data [LOCALSTATEDIR/run]
  --libdir=DIR            object code libraries [EPREFIX/lib]
  --includedir=DIR        C header files [PREFIX/include]
  --oldincludedir=DIR     C header files for non-gcc [/usr/include]
  --datarootdir=DIR       read-only arch.-independent data root [PREFIX/share]
  --datadir=DIR           read-only architecture-independent data [DATAROOTDIR]
  --infodir=DIR           info documentation [DATAROOTDIR/info]
  --localedir=DIR         locale-dependent data [DATAROOTDIR/locale]
  --mandir=DIR            man documentation [DATAROOTDIR/man]
  --docdir=DIR            documentation root [DATAROOTDIR/doc/freeipa]
  --htmldir=DIR           html documentation [DOCDIR]
  --dvidir=DIR            dvi documentation [DOCDIR]
  --pdfdir=DIR            pdf documentation [DOCDIR]
  --psdir=DIR             ps documentation [DOCDIR]

Program names:
  --program-prefix=PREFIX            prepend PREFIX to installed program names
  --program-suffix=SUFFIX            append SUFFIX to installed program names
  --program-transform-name=PROGRAM   run sed PROGRAM on installed program names

System types:
  --build=BUILD     configure for building on BUILD [guessed]
  --host=HOST       cross-compile to build programs to run on HOST [BUILD]

Optional Features:
  --disable-option-checking  ignore unrecognized --enable/--with options
  --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
  --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
  --enable-silent-rules   less verbose build output (undo: "make V=1")
  --disable-silent-rules  verbose build output (undo: "make V=0")
  --enable-dependency-tracking
                          do not reject slow dependency extractors
  --disable-dependency-tracking
                          speeds up one-time build
  --enable-static[=PKGS]  build static libraries [default=no]
  --enable-shared[=PKGS]  build shared libraries [default=yes]
  --enable-fast-install[=PKGS]
                          optimize for fast installation [default=yes]
  --disable-libtool-lock  avoid locking (might break parallel builds)
  --disable-server        Disable server support
  --disable-nls           do not use Native Language Support
  --disable-rpath         do not hardcode runtime library paths
  --enable-more-warnings  Maximum compiler warnings
  --disable-i18ntests     do not execute ipatests/i18n.py (depends on
                          python-polib)
  --enable-pylint         Require pylint. Default is autodetection with
                          "python -m pylint".

Optional Packages:
  --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
  --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
  --with-pic[=PKGS]       try to use only PIC/non-PIC objects [default=use
                          both]
  --with-aix-soname=aix|svr4|both
                          shared library versioning (aka "SONAME") variant to
                          provide on AIX, [default=aix].
  --with-gnu-ld           assume the C compiler uses GNU ld [default=no]
  --with-sysroot[=DIR]    Search for dependent libraries within DIR (or the
                          compiler's sysroot if not specified).
  --without-ipatests      Build without ipatests
  --with-sysconfenvdir=DIR
                          Directory for daemon environment files
  --with-systemdsystemunitdir=DIR
                          Directory for systemd service files
  --with-systemdtmpfilesdir=DIR
                          Directory for systemd-tmpfiles configuration files
  --with-gnu-ld           assume the C compiler uses GNU ld [default=no]
  --with-libiconv-prefix[=DIR]  search for libiconv in DIR/include and DIR/lib
  --without-libiconv-prefix     don't search for libiconv in includedir and libdir
  --with-libintl-prefix[=DIR]  search for libintl in DIR/include and DIR/lib
  --without-libintl-prefix     don't search for libintl in includedir and libdir
  --with-ipaplatform      IPA platform module to use
  --with-vendor-suffix=STRING
                          Vendor string used by package system, e.g. "-1.fc24"
  --with-jslint=FILE      path to JavaScript linter. Default is autodetection
                          of utility "jsl"

Some influential environment variables:
  CC          C compiler command
  CFLAGS      C compiler flags
  LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
              nonstandard directory <lib dir>
  LIBS        libraries to pass to the linker, e.g. -l<library>
  CPPFLAGS    (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
              you have headers in a nonstandard directory <include dir>
  LT_SYS_LIBRARY_PATH
              User-defined run-time library search path.
  CPP         C preprocessor
  PKG_CONFIG  path to pkg-config utility
  PKG_CONFIG_PATH
              directories to add to pkg-config's search path
  PKG_CONFIG_LIBDIR
              path overriding pkg-config's built-in search path
  NSPR_CFLAGS C compiler flags for NSPR, overriding pkg-config
  NSPR_LIBS   linker flags for NSPR, overriding pkg-config
  NSS_CFLAGS  C compiler flags for NSS, overriding pkg-config
  NSS_LIBS    linker flags for NSS, overriding pkg-config
  KRB5_CFLAGS C compiler flags for KRB5, overriding pkg-config
  KRB5_LIBS   linker flags for KRB5, overriding pkg-config
  CRYPTO_CFLAGS
              C compiler flags for CRYPTO, overriding pkg-config
  CRYPTO_LIBS linker flags for CRYPTO, overriding pkg-config
  PYTHON      the Python interpreter
  CMOCKA_CFLAGS
              C compiler flags for CMOCKA, overriding pkg-config
  CMOCKA_LIBS linker flags for CMOCKA, overriding pkg-config
  POPT_CFLAGS C compiler flags for POPT, overriding pkg-config
  POPT_LIBS   linker flags for POPT, overriding pkg-config
  SASL_CFLAGS C compiler flags for SASL, overriding pkg-config
  SASL_LIBS   linker flags for SASL, overriding pkg-config
  XMLRPC_CFLAGS
              C compiler flags for XMLRPC, overriding pkg-config
  XMLRPC_LIBS linker flags for XMLRPC, overriding pkg-config
  INI_CFLAGS  C compiler flags for INI, overriding pkg-config
  INI_LIBS    linker flags for INI, overriding pkg-config
  DIRSRV_CFLAGS
              C compiler flags for DIRSRV, overriding pkg-config
  DIRSRV_LIBS linker flags for DIRSRV, overriding pkg-config
  SSSIDMAP_CFLAGS
              C compiler flags for SSSIDMAP, overriding pkg-config
  SSSIDMAP_LIBS
              linker flags for SSSIDMAP, overriding pkg-config
  SSSNSSIDMAP_CFLAGS
              C compiler flags for SSSNSSIDMAP, overriding pkg-config
  SSSNSSIDMAP_LIBS
              linker flags for SSSNSSIDMAP, overriding pkg-config
  SSSCERTMAP_CFLAGS
              C compiler flags for SSSCERTMAP, overriding pkg-config
  SSSCERTMAP_LIBS
              linker flags for SSSCERTMAP, overriding pkg-config
  UUID_CFLAGS C compiler flags for UUID, overriding pkg-config
  UUID_LIBS   linker flags for UUID, overriding pkg-config
  TALLOC_CFLAGS
              C compiler flags for TALLOC, overriding pkg-config
  TALLOC_LIBS linker flags for TALLOC, overriding pkg-config
  TEVENT_CFLAGS
              C compiler flags for TEVENT, overriding pkg-config
  TEVENT_LIBS linker flags for TEVENT, overriding pkg-config
  NDRPAC_CFLAGS
              C compiler flags for NDRPAC, overriding pkg-config
  NDRPAC_LIBS linker flags for NDRPAC, overriding pkg-config
  NDRNBT_CFLAGS
              C compiler flags for NDRNBT, overriding pkg-config
  NDRNBT_LIBS linker flags for NDRNBT, overriding pkg-config
  NDR_CFLAGS  C compiler flags for NDR, overriding pkg-config
  NDR_LIBS    linker flags for NDR, overriding pkg-config
  SAMBAUTIL_CFLAGS
              C compiler flags for SAMBAUTIL, overriding pkg-config
  SAMBAUTIL_LIBS
              linker flags for SAMBAUTIL, overriding pkg-config
  LIBVERTO_CFLAGS
              C compiler flags for LIBVERTO, overriding pkg-config
  LIBVERTO_LIBS
              linker flags for LIBVERTO, overriding pkg-config

Use these variables to override the choices made by `configure' or to help
it to find libraries and programs with nonstandard names/locations.

Report bugs to <https://hosted.fedoraproject.org/projects/freeipa/newticket>.
```

Testing
-------

[![Build Status](https://travis-ci.org/timorunge/ansible-freeipa.svg?branch=master)](https://travis-ci.org/timorunge/ansible-freeipa)

Testing is done with [Docker Compose](https://docs.docker.com/compose/) which
is bringing up the following containers:

* Debian 9.4 (Stretch)
* Ubuntu 18.04 (Bionic Beaver)
* Ubuntu 18.10 (Cosmic Cuttlefish)

Ansible 2.6.2 is installed on all containers and is applying two test
playbooks:

* [test-from-pkgs.yml](tests/test-from-pkgs.yml)
* [test-from-3rdparty-sssd-pkgs.yml](tests/test-from-3rdparty-sssd-pkgs.yml)

For further details and additional checks take a look at the
[Docker entrypoint](docker/docker-entrypoint.sh).

```sh
# Testing locally with docker-compose:
docker-compose config
docker-compose pull
docker-compose build
docker-compose up --no-start
docker-compose up
docker-compose down
```

Since the build time on Travis is limited for public repositories the
[automated tests](.travis-docker-compose.yml) are limited to:

* Debian 9.4 (Stretch)
* Ubuntu 18.04 (Bionic Beaver)

Dependencies
------------

If you want to install FreeIPA (4.6.4) on Debian 9.4 you have to ensure that
you have:

* libsss-idmap >= 1.15.2
* libsss-nss-idmap >= 1.15.2

You can check this with `pkg-config`:

```sh
pkg-config --modversion sss_idmap
pkg-config --modversion sss_nss_idmap
```

Since Debian 9.4 is not providing the SSSD package binaries you can use the
following Ansible role:
* [timorunge.sssd](https://github.com/timorunge/ansible-sssd)

Take a look at [example 4](#4-install-freeipa-with-timorungesssd).

License
-------
BSD

Author Information
------------------

- Timo Runge

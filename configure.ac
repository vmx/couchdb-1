dnl Licensed under the Apache License, Version 2.0 (the "License"); you may not
dnl use this file except in compliance with the License.  dnl You may obtain a
dnl copy of the License at
dnl
dnl   http://www.apache.org/licenses/LICENSE-2.0
dnl
dnl Unless required by applicable law or agreed to in writing, software
dnl distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
dnl WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
dnl License for the specific language governing permissions and limitations
dnl under the License.

AC_INIT([LOCAL_PACKAGE_NAME], [LOCAL_VERSION], [], [LOCAL_PACKAGE_TARNAME])

AC_PREREQ([2.59])

AC_CONFIG_SRCDIR([CHANGES])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])

AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([1.6.3 foreign])

AC_GNU_SOURCE
AC_ENABLE_SHARED
AC_DISABLE_STATIC

AC_PROG_CC
AC_PROG_LIBTOOL
AC_PROG_LN_S

dnl Config for google snappy
m4_define([snappy_major], [1])
m4_define([snappy_minor], [0])
m4_define([snappy_patchlevel], [4])
AC_CONFIG_HEADERS([src/snappy/snappy-1.0.4/config.h])

AC_PROG_CXX
AC_LANG([C++])
AC_C_BIGENDIAN
AC_CHECK_HEADERS([stdint.h stddef.h sys/mman.h sys/resource.h])
AC_CHECK_FUNC([mmap])

AC_MSG_CHECKING([if the compiler supports __builtin_expect])

AC_TRY_COMPILE(, [
    return __builtin_expect(1, 1) ? 1 : 0
], [
    snappy_have_builtin_expect=yes
    AC_MSG_RESULT([yes])
], [
    snappy_have_builtin_expect=no
    AC_MSG_RESULT([no])
])
if test x$snappy_have_builtin_expect = xyes ; then
    AC_DEFINE([HAVE_BUILTIN_EXPECT], [1], [Define to 1 if the compiler supports __builtin_expect.])
fi

AC_MSG_CHECKING([if the compiler supports __builtin_ctzll])

AC_TRY_COMPILE(, [
    return (__builtin_ctzll(0x100000000LL) == 32) ? 1 : 0
], [
    snappy_have_builtin_ctz=yes
    AC_MSG_RESULT([yes])
], [
    snappy_have_builtin_ctz=no
    AC_MSG_RESULT([no])
])
if test x$snappy_have_builtin_ctz = xyes ; then
    AC_DEFINE([HAVE_BUILTIN_CTZ], [1], [Define to 1 if the compiler supports __builtin_ctz and friends.])
fi

if test "$ac_cv_header_stdint_h" = "yes"; then
    AC_SUBST([ac_cv_have_stdint_h], [1])
else
    AC_SUBST([ac_cv_have_stdint_h], [0])
fi
if test "$ac_cv_header_stddef_h" = "yes"; then
    AC_SUBST([ac_cv_have_stddef_h], [1])
else
    AC_SUBST([ac_cv_have_stddef_h], [0])
fi

SNAPPY_MAJOR="snappy_major"
SNAPPY_MINOR="snappy_minor"
SNAPPY_PATCHLEVEL="snappy_patchlevel"

AC_SUBST([SNAPPY_MAJOR])
AC_SUBST([SNAPPY_MINOR])
AC_SUBST([SNAPPY_PATCHLEVEL])
dnl End of google snappy specific config

AC_MSG_CHECKING([for pthread_create in -lpthread])

original_LIBS="$LIBS"
LIBS="-lpthread $original_LIBS"

AC_TRY_LINK([#include<pthread.h>],
    [pthread_create((void *)0, (void *)0, (void *)0, (void *)0)],
    [pthread=yes], [pthread=no])

if test x${pthread} = xyes; then
    AC_MSG_RESULT([yes])
else
    LIBS="$original_LIBS"
    AC_MSG_RESULT([no])
fi

AC_PATH_PROG([ERL], [erl])
AS_IF([test x${ERL} = x], [
    AC_MSG_ERROR([Could not find the `erl' executable. Is Erlang installed?])
    ])

AC_ARG_WITH([erlang], [AC_HELP_STRING([--with-erlang=PATH],
    [set PATH to the Erlang include directory])], [
    ERLANG_INCLUDE="$withval"
    ERLANG_FLAGS="-I$ERLANG_INCLUDE"
    AC_SUBST(ERLANG_INCLUDE)
], [
    realerl=`readlink -f $ERL 2>/dev/null`
    AS_IF([test $? -eq 0], [
           erlbase=`dirname $realerl`
           erlbase=`dirname $erlbase`
           ERLANG_FLAGS="-I${erlbase}/usr/include"
          ], [
           # Failed to figure out where erl is installed..
           # try to add some default directories to search
           ERLANG_FLAGS="-I${libdir}/erlang/usr/include"
           ERLANG_FLAGS="$ERLANG_FLAGS -I/usr/lib/erlang/usr/include"
           ERLANG_FLAGS="$ERLANG_FLAGS -I/usr/local/lib/erlang/usr/include"
           ERLANG_FLAGS="$ERLANG_FLAGS -I/opt/local/lib/erlang/usr/include"
          ])
])

ERL_INTERFACE_DIR_INCLUDE="-I`${ERL} -eval 'io:put_chars(code:lib_dir(erl_interface) ++ "/include"), timer:sleep(10), erlang:halt().' -noshell -noinput`"
AC_SUBST(ERL_INTERFACE_DIR_INCLUDE)

ERL_INTERFACE_DIR_LIB="-L`${ERL} -eval 'io:put_chars(code:lib_dir(erl_interface) ++ "/lib"), timer:sleep(10), erlang:halt().' -noshell -noinput`"
AC_SUBST(ERL_INTERFACE_DIR_LIB)

AC_ARG_VAR([ERLC_FLAGS], [general flags to prepend to ERLC_FLAGS])
AC_ARG_VAR([FLAGS], [general flags to prepend to LDFLAGS and CPPFLAGS])

ac_test_ERLC_FLAGS=${ERLC_FLAGS+set}
if test "$ac_test_ERLCFLAGS" != set; then
  ERLC_FLAGS="+debug_info -Werror +nowarn_deprecated_function"
fi

LIB_FLAGS="-L/usr/local/lib -L/opt/local/lib"
LIBS="$LIB_FLAGS $LIBS"

case "$(uname -s)" in
  CYGWIN*|MINGW*)
    FLAGS="$LIB_FLAGS $ERLANG_FLAGS -DXP_WIN $FLAGS"
    CPPFLAGS="$FLAGS $CPPFLAGS"
    LDFLAGS="$FLAGS $LDFLAGS"
    IS_WINDOWS="TRUE"
    # The erlang cc.sh/ld.sh scripts will convert a -O option
    # into the same optimization flags erlang itself uses.
    CFLAGS="-O2"
    LTCFLAGS="$CFLAGS"
    ;;
  *)
    # XP_UNIX required for jsapi.h and has been tested to work on Linux and Darwin.
    FLAGS="$LIB_FLAGS $ERLANG_FLAGS -DXP_UNIX $FLAGS"
    CPPFLAGS="$FLAGS $CPPFLAGS"
    # manually linking libm is requred for FreeBSD 7.0
    LDFLAGS="$FLAGS -lm $LDFLAGS"
    ;;
esac

AM_CONDITIONAL([WINDOWS], [test x$IS_WINDOWS = xTRUE])
AM_CONDITIONAL([GCC], [ test x$GCC = xyes])

AC_ARG_ENABLE([v8],
    [AS_HELP_STRING([--disable-v8],
            [Allow to build without the V8 library @<:@default=off@:>@])],
    [ac_enable_v8="$enableval"],
    [ac_enable_v8="yes"])

AM_CONDITIONAL([BUILD_MAPREDUCE], [ test "x${ac_enable_v8}" = "xyes" ])

AS_IF([ test "x${ac_enable_v8}" = "xyes" ], [
    AC_ARG_WITH([v8-lib], [AC_HELP_STRING([--with-v8-lib=PATH],
        [set PATH to the V8 library directory])],
        [
            V8_LIB_DIR=$withval
            V8_LIB_FLAGS="-L$withval -lv8"
        ], [
            V8_LIB_FLAGS="-lv8"
    ])
    AC_SUBST(V8_LIB_DIR)
    LDFLAGS="$V8_LIB_FLAGS $LDFLAGS"

    AC_ARG_WITH([v8-include], [AC_HELP_STRING([--with-v8-include=PATH],
        [set PATH to the V8 include directory])], [
            V8_INCLUDE="$withval"
            V8_FLAGS="-I$V8_INCLUDE"
        ], [
            V8_FLAGS="-I/usr/include/v8"
            V8_FLAGS="$V8_FLAGS -I/opt/local/include"
            V8_FLAGS="$V8_FLAGS -I/usr/local/include/v8"
            V8_FLAGS="$V8_FLAGS -I/opt/local/include/v8"
    ])
    AC_SUBST(V8_INCLUDE)
    CPPFLAGS="$V8_FLAGS $CPPFLAGS"

    AC_CHECK_HEADER([v8.h], [], [AC_MSG_ERROR([Could not find the V8 JavaScript engine library.])])
    # V8 library has no exported C functions, so we can't use AC_CHECK_LIB
    # TODO: find an alternative
    # AC_CHECK_LIB([v8], [exported-C-function], [V8_LIB_BASE=v8],
    #     [AC_MSG_ERROR([Could not find the V8 JavaScript engine library.])])
])

if test x${IS_WINDOWS} = xTRUE; then
        # On windows we need to know the path to the openssl binaries.
        AC_ARG_WITH([openssl-bin-dir], [AC_HELP_STRING([--with-openssl-bin-dir=PATH],
            [path to the open ssl binaries for distribution on Windows])], [
            openssl_bin_dir=`cygpath -m "$withval"`
            AC_SUBST(openssl_bin_dir)
        ], [])

        # Windows uses Inno setup - look for its compiler.
        AC_PATH_PROG([INNO_COMPILER_EXECUTABLE], [iscc])
        if test x${INNO_COMPILER_EXECUTABLE} = x; then
            AC_MSG_WARN([You will be unable to build the Windows installer.])
        fi

        # We need the msvc redistributables for this platform too
        # (in theory we could just install the assembly locally - but
        # there are at least 4 directories with binaries, meaning 4 copies;
        # so using the redist .exe means it ends up installed globally...)
        AC_ARG_WITH([msvc-redist-dir], [AC_HELP_STRING([--with-msvc-redist-dir=PATH],
            [path to the msvc redistributables for the Windows platform])], [
            msvc_redist_dir=`cygpath -m "$withval"`
            msvc_redist_name="vcredist_x86.exe"
            AC_SUBST(msvc_redist_dir)
            AC_SUBST(msvc_redist_name)
        ], [])
        if test ! -f ${msvc_redist_dir}/${msvc_redist_name}; then
            AC_MSG_WARN([The MSVC redistributable seems to be missing; expect the installer to fail.])
        fi

        # We need the msvc redistributables for this platform too
        # (in theory we could just install the assembly locally - but
        # there are at least 4 directories with binaries, meaning 4 copies;
        # so using the redist .exe means it ends up installed globally...)
        AC_ARG_WITH([msvc-redist-dir], [AC_HELP_STRING([--with-msvc-redist-dir=PATH],
            [path to the msvc redistributables for the Windows platform])], [
            msvc_redist_dir=$withval
            msvc_redist_name="vcredist_x86.exe"
            AC_SUBST(msvc_redist_dir)
            AC_SUBST(msvc_redist_name)
        ], [])
        if test ! -f ${msvc_redist_dir}/${msvc_redist_name}; then
            AC_MSG_WARN([The MSVC redistributable seems to be missing; expect the installer to fail.])
        fi

        # On windows we need to know the path to the MSBuild
        AC_ARG_WITH([msbuild-dir], [AC_HELP_STRING([--with-msbuild-dir=PATH],
            [path to the .NET Framework 4 which contains MSBuild.exe])], [
            msbuild_dir=$withval
            msbuild_name="MSBuild.exe"
            AC_SUBST(msbuild_dir)
            AC_SUBST(msbuild_name)
        ], [])
        if test ! -f ${msbuild_dir}/${msbuild_name}; then
            AC_MSG_WARN([The .NET Framework 4.0 seems to be missing; expect the couchjs module to fail.])
        fi
fi

AC_ARG_WITH([win32-icu-binaries], [AC_HELP_STRING([--with-win32-icu-binaries=PATH],
    [set PATH to the Win32 native ICU binaries directory])], [
    ICU_CONFIG="" # supposed to be a command to query options...
    ICU_INCLUDE="$withval/include"
    ICU_LOCAL_CFLAGS="-I$ICU_INCLUDE"
    ICU_LIB_DIR="$withval/lib"
    ICU_LOCAL_LDFLAGS="-L$ICU_LIB_DIR"
    ICU_LOCAL_BIN=$withval/bin
    AC_SUBST(ICU_INCLUDE)
    AC_SUBST(ICU_LIB_DIR)
], [
    AC_CHECK_ICU([3.4.1])
    ICU_LOCAL_CFLAGS=`$ICU_CONFIG --cppflags-searchpath`
    ICU_LOCAL_LDFLAGS=`$ICU_CONFIG --ldflags-searchpath`
    ICU_LOCAL_BIN=
])

AC_SUBST(ICU_CONFIG)
AC_SUBST(ICU_LOCAL_CFLAGS)
AC_SUBST(ICU_LOCAL_LDFLAGS)
AC_SUBST(ICU_LOCAL_BIN)

use_curl=yes
AC_ARG_WITH([win32-curl], [AC_HELP_STRING([--with-win32-curl=PATH],
    [set PATH to the Win32 native curl directory])], [
    # default build on windows is a static lib, and that's what we want too
    CURL_CFLAGS="-I$withval/include -DCURL_STATICLIB"
    CURL_LIBS="-L$withval/lib -lcurl -lWs2_32 -lkernel32 -luser32 -ladvapi32 -lWldap32"
], [
    AC_CHECK_CURL([7.18.0],
        [AC_DEFINE([HAVE_CURL], [1], ["Provide HTTP support to couchjs"])], [
        AC_MSG_WARN([You will be unable to run some JavaScript unit tests.])
        use_curl=no
        CURL_LIBS=
    ])
])

AC_SUBST(CURL_CFLAGS)
AC_SUBST(CURL_LIBS)

case "$(uname -s)" in
  Linux)
    LIBS="$LIBS -lcrypt"
    CPPFLAGS="-D_XOPEN_SOURCE $CPPFLAGS"
    ;;
  FreeBSD)
    LIBS="$LIBS -lcrypt"
    ;;
  OpenBSD)
    LIBS="$LIBS -lcrypto"
  ;;
esac


erlang_version_error="The installed Erlang version is less than 5.6.5 (R12B05)."

version="`${ERL} -version 2>&1 | ${SED} 's/[[^0-9]]/ /g'`"

if test `echo $version | ${AWK} "{print \\$1}"` -lt 5; then
    AC_MSG_ERROR([$erlang_version_error])
fi

if test `echo $version | ${AWK} "{print \\$2}"` -lt 6; then
    AC_MSG_ERROR([$erlang_version_error])
fi

if test `echo $version | ${AWK} "{print \\$2}"` -eq 6; then
    if test `echo $version | ${AWK} "{print \\$3}"` -lt 5; then
        AC_MSG_ERROR([$erlang_version_error])
    fi
fi

otp_release="`${ERL} -noshell -eval 'io:put_chars(erlang:system_info(otp_release)).' -s erlang halt`"
AC_SUBST(otp_release)
AM_CONDITIONAL([USE_OTP_NIFS], [test x$otp_release \> xR13B03])

has_crypto=`${ERL} -eval "case application:load(crypto) of ok -> ok; _ -> exit(no_crypto) end." -noshell -s init stop`

if test -n "$has_crypto"; then
    AC_MSG_ERROR([Could not find the Erlang crypto library. Has Erlang been compiled with OpenSSL support?])
fi

AC_PATH_PROG([ERLC], [erlc])

if test x${ERLC} = x; then
    AC_MSG_ERROR([Could not find the `erlc' executable. Is Erlang installed?])
fi

AC_CHECK_HEADER([erl_driver.h], [], [
    AC_MSG_ERROR([Could not find the `erl_driver.h' header.

Are the Erlang headers installed? Use the `--with-erlang' option to specify the
path to the Erlang include directory.])])

AC_PATH_PROG([HELP2MAN_EXECUTABLE], [help2man])
if test x${HELP2MAN_EXECUTABLE} = x; then
    AC_MSG_WARN([You will be unable to regenerate any man pages.])
fi

use_init=yes
use_launchd=yes
native_mochijson_enabled=no

AC_ARG_ENABLE([init], [AC_HELP_STRING([--disable-init],
    [don't install init script where applicable])], [
    use_init=$enableval
], [])

AC_ARG_ENABLE([launchd], [AC_HELP_STRING([--disable-launchd],
    [don't install launchd configuration where applicable])], [
    use_launchd=$enableval
], [])

AC_ARG_ENABLE([native-mochijson], [AC_HELP_STRING([--enable-native-mochijson],
    [compile mochijson to native code (EXPERIMENTAL)])], [
    native_mochijson_enabled=$enableval
], [])

init_enabled=false
launchd_enabled=false

if test "$use_init" = "yes"; then
   AC_MSG_CHECKING(location of init directory)
   if test -d /etc/rc.d; then
       init_enabled=true
       AC_SUBST([initdir], ['${sysconfdir}/rc.d'])
       AC_MSG_RESULT(${initdir})
   else
       if test -d /etc/init.d; then
           init_enabled=true
           AC_SUBST([initdir], ['${sysconfdir}/init.d'])
           AC_MSG_RESULT(${initdir})
       else
           AC_MSG_RESULT(not found)
       fi
    fi
fi

if test "$use_launchd" = "yes"; then
    AC_MSG_CHECKING(location of launchd directory)
    if test -d /Library/LaunchDaemons; then
        init_enabled=false
        launchd_enabled=true
        AC_SUBST([launchddir], ['${prefix}/Library/LaunchDaemons'])
        AC_MSG_RESULT(${launchddir})
    else
        AC_MSG_RESULT(not found)
    fi
fi

AC_ARG_VAR([ERL], [path to the `erl' executable])
AC_ARG_VAR([ERLC], [path to the `erlc' executable])
AC_ARG_VAR([ICU_CONFIG], [path to the `icu-config' executable])
AC_ARG_VAR([CURL_CONFIG], [path to the `curl-config' executable])
AC_ARG_VAR([HELP2MAN_EXECUTABLE], [path to the `help2man' program])

if test -n "$HELP2MAN_EXECUTABLE"; then
    help2man_enabled=true
else
    if test -f "$srcdir/bin/couchdb.1"; then
        help2man_enabled=true
    else
        help2man_enabled=false
    fi
fi

AM_CONDITIONAL([INIT], [test x${init_enabled} = xtrue])
AM_CONDITIONAL([LAUNCHD], [test x${launchd_enabled} = xtrue])
AM_CONDITIONAL([HELP2MAN], [test x${help2man_enabled} = xtrue])
AM_CONDITIONAL([USE_NATIVE_MOCHIJSON], [test x${native_mochijson_enabled} = xyes])
AM_CONDITIONAL([USE_CURL], [test x${use_curl} = xyes])

AC_SUBST([package_author_name], ["LOCAL_PACKAGE_AUTHOR_NAME"])
AC_SUBST([package_author_address], ["LOCAL_PACKAGE_AUTHOR_ADDRESS"])
AC_SUBST([package_identifier], ["LOCAL_PACKAGE_IDENTIFIER"])
AC_SUBST([package_tarname], ["LOCAL_PACKAGE_TARNAME"])
AC_SUBST([package_name], ["LOCAL_PACKAGE_NAME"])

AC_SUBST([version], ["LOCAL_VERSION"])
AC_SUBST([version_major], ["LOCAL_VERSION_MAJOR"])
AC_SUBST([version_minor], ["LOCAL_VERSION_MINOR"])
AC_SUBST([version_revision], ["LOCAL_VERSION_REVISION"])
AC_SUBST([version_stage], ["LOCAL_VERSION_STAGE"])
AC_SUBST([version_release], ["LOCAL_VERSION_RELEASE"])

AC_SUBST([bug_uri], ["LOCAL_BUG_URI"])

AC_SUBST([localconfdir], [${sysconfdir}/${package_identifier}])
AC_SUBST([localdatadir], [${datadir}/${package_identifier}])
AC_SUBST([localdocdir], [${datadir}/doc/${package_identifier}])
AC_SUBST([locallibdir], [${libdir}/${package_identifier}])
AC_SUBST([localstatelibdir], [${localstatedir}/lib/${package_identifier}])
AC_SUBST([localstatelogdir], [${localstatedir}/log/${package_identifier}])
AC_SUBST([localstaterundir], [${localstatedir}/run/${package_identifier}])

# On Windows we install directly into our erlang distribution.
if test x${IS_WINDOWS} = xTRUE; then
    AC_SUBST([locallibbindir], [${prefix}/bin])
    AC_SUBST([localerlanglibdir], [${libdir}])
else
    AC_SUBST([locallibbindir], [${locallibdir}/bin])
    AC_SUBST([localerlanglibdir], [${locallibdir}/erlang/lib])
    AC_SUBST([localerl_interfacelibdir], [${locallibdir}/erlang/lib])
    AC_SUBST([localerl_interfaceincdir], [${locallibdir}/erlang/lib])
fi

# fix for older autotools that don't define "abs_top_YYY" by default
AC_SUBST(abs_top_srcdir)
AC_SUBST(abs_top_builddir)

AC_REVISION([LOCAL_VERSION])

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([bin/couchjs.tpl])
AC_CONFIG_FILES([bin/couchdb.tpl])
AC_CONFIG_FILES([bin/couchdb.bat.tpl])
AC_CONFIG_FILES([bin/Makefile])
AC_CONFIG_FILES([etc/couchdb/Makefile])
AC_CONFIG_FILES([etc/couchdb/default.ini.tpl])
AC_CONFIG_FILES([etc/default/Makefile])
AC_CONFIG_FILES([etc/init/couchdb.tpl])
AC_CONFIG_FILES([etc/init/Makefile])
AC_CONFIG_FILES([etc/launchd/org.apache.couchdb.plist.tpl])
AC_CONFIG_FILES([etc/launchd/Makefile])
AC_CONFIG_FILES([etc/logrotate.d/couchdb.tpl])
AC_CONFIG_FILES([etc/logrotate.d/Makefile])
AC_CONFIG_FILES([etc/windows/Makefile])
AC_CONFIG_FILES([etc/Makefile])
AC_CONFIG_FILES([share/Makefile])
AC_CONFIG_FILES([src/Makefile])
AC_CONFIG_FILES([src/couchdb/couch.app.tpl])
AC_CONFIG_FILES([src/couchdb/Makefile])
AC_CONFIG_FILES([src/couchdb/priv/Makefile])
AC_CONFIG_FILES([src/erlang-oauth/Makefile])
AC_CONFIG_FILES([src/etap/Makefile])
AC_CONFIG_FILES([src/lhttpc/Makefile])
AC_CONFIG_FILES([src/mochiweb/Makefile])
AC_CONFIG_FILES([src/snappy/Makefile])
AC_CONFIG_FILES([src/snappy/snappy-$SNAPPY_MAJOR.$SNAPPY_MINOR.$SNAPPY_PATCHLEVEL/snappy-stubs-public.h])
AC_CONFIG_FILES([src/ejson/Makefile])
AC_CONFIG_FILES([src/couch_set_view/Makefile])
AC_CONFIG_FILES([src/couch_index_merger/Makefile])
AC_CONFIG_FILES([src/couch_view_parser/Makefile])
AS_IF([ test "x${ac_enable_v8}" = "xyes" ], [
    AC_CONFIG_FILES([src/mapreduce/Makefile])
])
AC_CONFIG_FILES([test/Makefile])
AC_CONFIG_FILES([test/bench/Makefile])
AC_CONFIG_FILES([test/etap/Makefile])
AC_CONFIG_FILES([test/etap/test_util.erl])
AC_CONFIG_FILES([test/javascript/Makefile])
AC_CONFIG_FILES([test/view_server/Makefile])
AC_CONFIG_FILES([test/python/Makefile])
AC_CONFIG_FILES([test/python/set_view/Makefile])
AC_CONFIG_FILES([utils/Makefile])
if test x${IS_WINDOWS} = xTRUE; then
    AC_CONFIG_FILES([src/couchdb/priv/icu_driver/win32/msbuild.bat.tpl])
    AC_CONFIG_FILES([src/couchdb/priv/icu_driver/win32/couch_icu_driver.vcxproj.tpl])
    AC_CONFIG_FILES([src/couchdb/priv/couch_ejson_compare/win32/msbuild.bat.tpl])
    AC_CONFIG_FILES([src/couchdb/priv/couch_ejson_compare/win32/couch_ejson_compare.vcxproj.tpl])
    AC_CONFIG_FILES([src/ejson/win32/msbuild.bat.tpl])
    AC_CONFIG_FILES([src/ejson/win32/ejson.vcxproj.tpl])
    AS_IF([ test "x${ac_enable_v8}" = "xyes" ], [
        AC_CONFIG_FILES([src/mapreduce/win32/msbuild.bat.tpl])
        AC_CONFIG_FILES([src/mapreduce/win32/mapreduce.vcxproj.tpl])
    ])
    AC_CONFIG_FILES([src/snappy/win32/msbuild.bat.tpl])
    AC_CONFIG_FILES([src/snappy/win32/snappy.vcxproj.tpl])
fi
AC_OUTPUT

# *sob* - on Windows libtool fails as 'libname_spec' isn't correct (it
# expects GNU style lib names).  I can't work out how to configure this
# option sanely, so we pass the script through sed to modify it.
# Also, the erlang cc.sh script doesn't cope well with the '-link' command
# line option libtool provides.
# PLEASE, someone help put this out of its misery!!
# This hackery is being tracked via COUCHDB-440.
if test x${IS_WINDOWS} = xTRUE; then
    sed -e 's,libname_spec="lib\\$name",libname_spec="\\\$name",' \
        -e 's,-link,,' \
        < libtool > libtool.tmp
    mv libtool.tmp libtool
    # probably would chmod +x if we weren't on windows...
fi

echo
echo "You have configured Apache CouchDB, time to relax."
echo
echo "Run \`make && sudo make install' to install."

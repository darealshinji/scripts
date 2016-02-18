# The MIT License (MIT)
# 
# Copyright (c) 2015-2016, djcj <djcj@gmx.de>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# usage: AX_CHECK_PKG_LIB(prefix, pkg-module, library, headers)
_AX_CHECK_PKG_LIB_lang="C++"
m4_define([AX_CHECK_PKG_LIB], [{
    AC_LANG_PUSH([$_AX_CHECK_PKG_LIB_lang])
    PKG_CHECK_MODULES([$1], [$2], [], [
        # library check
        LIBS_backup="$LIBS"
        LIBS="-l$3"
        AC_MSG_CHECKING([for -l$3])
        AC_LINK_IFELSE([
            AC_LANG_SOURCE(
                [[int main() { return 0; }]]
            )
        ], [AC_MSG_RESULT([found])],
           [AC_MSG_ERROR([$3 not found])]
        )
        LIBS="$LIBS_backup -l$3"
        # header checks
        AS_IF([test "x$4" != "x"], [
            AC_CHECK_HEADERS([$4], [], [exit 1])
        ])
    ])
    AC_LANG_POP([$_AX_CHECK_PKG_LIB_lang])
}])

# usage: AX_CHECK_CXXFLAGS(flags)
m4_define([AX_CHECK_CXXFLAGS], [{
    CXXFLAGS_backup="$CXXFLAGS"
    CXXFLAGS="-Werror $1"
    AC_MSG_CHECKING([if $CXX understands $1])
    AC_LANG_PUSH([C++])
    AC_COMPILE_IFELSE([
        AC_LANG_SOURCE(
            [[int main() { return 0; }]]
        )
    ], [AC_MSG_RESULT([yes])
        addflag="$1"],
       [AC_MSG_RESULT([no])]
    )
    CXXFLAGS="$addflag $CXXFLAGS_backup"
    AC_LANG_POP([C++])
}])

# usage: AX_CHECK_CFLAGS(flags)
m4_define([AX_CHECK_CFLAGS], [{
    CFLAGS_backup="$CFLAGS"
    CFLAGS="-Werror $1"
    AC_MSG_CHECKING([if $CC understands $1])
    AC_LANG_PUSH([C])
    AC_COMPILE_IFELSE([
        AC_LANG_SOURCE(
            [[int main() { return 0; }]]
        )
    ], [AC_MSG_RESULT([yes])
        addflag="$1"],
       [AC_MSG_RESULT([no])]
    )
    CFLAGS="$addflag $CFLAGS_backup"
    AC_LANG_POP([C])
}])


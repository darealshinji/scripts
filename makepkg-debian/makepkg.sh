#!/bin/bash

set -e

# Copyright (c) 2015, djcj <djcj@gmx.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

basedir="${PWD}"
pkgbuild="${basedir}/PKGBUILD.debian"
installsrc="debian_tmp"
debugpkg=0

showhelp() {
  cat <<EOL
 usage: ${0}
        ${0} <PKGBUILD.debian>
        ${0} <options>

 options:
   --help, -h   print this help
   --env, -e    display the default environment variables

 available PKGBUILD.debian helper functions:
   _configure  _cmake  _qmake  _qmake-qt4  _make  _make_install

EOL
  exit 0
}

showenv() {
  cat <<EOL
$(dpkg-architecture)
$(dpkg-buildflags --export=sh | sed -e 's|-Wl,-Bsymbolic-functions ||; s|^export ||g')
EOL
  exit 0
}

for opt; do
  optarg="${opt#*=}"
  case "$opt" in
    "--help"|"-h")
      showhelp
      ;;
    "--env"|"-e")
      showenv
      ;;
    *)
      pkgbuild="$optarg"
      ;;
  esac
done


# set environment variables
eval `dpkg-architecture -s`
eval `dpkg-buildflags --export=sh | sed -e 's|-Wl,-Bsymbolic-functions ||'`

_configure() {
  CXXFLAGS="$CXXFLAGS $CPPFLAGS" \
  ./configure \
    --build=${DEB_HOST_GNU_TYPE} \
    --prefix=/usr \
    --includedir=\${prefix}/include \
    --mandir=\${prefix}/share/man \
    --infodir=\${prefix}/share/info \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --libdir=\${prefix}/lib/${DEB_HOST_MULTIARCH} \
    --libexecdir=\${prefix}/lib/${DEB_HOST_MULTIARCH} \
    --disable-maintainer-mode \
    --disable-dependency-tracking  $*
}

_cmake() {
  cmake \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DLIB_INSTALL_DIR=lib/${DEB_HOST_MULTIARCH} \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DCMAKE_BUILD_TYPE=None  $*
}

qmake_flags="\
  -makefile -nocache \
  \"QMAKE_CFLAGS_RELEASE=$CFLAGS $CPPFLAGS\" \
  \"QMAKE_CFLAGS_DEBUG=$CFLAGS $CPPFLAGS\" \
  \"QMAKE_CXXFLAGS_RELEASE=$CXXFLAGS $CPPFLAGS\" \
  \"QMAKE_CXXFLAGS_DEBUG=-$CXXFLAGS $CPPFLAGS\" \
  \"QMAKE_LFLAGS_RELEASE=$LDFLAGS\" \
  \"QMAKE_LFLAGS_DEBUG=$LDFLAGS\" \
  QMAKE_STRIP=: \
  PREFIX=/usr"

_qmake() {
  qmake $qmake_flags $*
}

_qmake-qt4() {
  qmake-qt4 $qmake_flags $*
}

_make() {
  jobs="$(nproc)"
  if [ ${jobs} -lt 1 ]; then jobs=1; fi
  make -j${jobs} V=1 $*
}

_download() {
  # $1 = URL, $2 = file, $3 = MD5 checksum
  if [ -f "${2}" ]; then
    echo "\`${2}' already in working directory"
  else
    wget -O "${2}" "${1}"
  fi
  echo "${3} ${2}" | md5sum -c
}


source "${pkgbuild}"


clean() {
  rm -rf debian debian_tmp ${cleanfiles}
  [ ! -f Makefile ] || (make distclean 2>/dev/null || make clean 2>/dev/null || true)
}

install_builddeps() {
  alldeps="build-essential debhelper fakeroot ${builddepends}"
  for dep in ${alldeps}; do
    if [ $(dpkg-query -W -f='${Status}' ${dep} 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
      installdeps="${dep} ${installdeps}"
    fi
  done
  if [ -n "${installdeps}" ]; then
    echo "The following build-dependencies need to be installed:"
    echo "${installdeps}"
    sudo -k -- sh -c "apt-get install ${installdeps}; apt-mark auto ${installdeps}"
  fi
}

pkgcount=$(echo ${packages[*]} | wc -w)

_make_install() {
  mkdir -p "${installsrc}"
  make install DESTDIR="${PWD}/${installsrc}" $*
}

gen_debian() {
  mkdir -p debian/source
  cd debian
  echo "3.0 (quilt)" > source/format
  echo "9" > compat

  # changelog
  cat <<EOF > changelog
${source} (${epoch}${pkgver}${pkgrev}) unstable; urgency=low

  * Package created with makepkg

 -- ${maintainer}  $(date -R)
EOF
  if [ "${epoch}${pkgver}${pkgrev}" != "${pkgver}" -a \
       "$(echo ${pkgrev} | head -c1)" != "~" -a \
       "$(echo ${pkgrev} | head -c2)" != "-0" ]; then
  cat <<EOF >> changelog

${source} (${pkgver}) unstable; urgency=low

  * Release version ${pkgver}

 -- ${maintainer}  $(echo "$(date -R | head -c-15)00:00:00 +0000")
EOF
  fi

  # control
  cat <<EOF > control
Source: ${source}
Section: ${section}
Priority: optional
Maintainer: ${maintainer}
Build-Depends: debhelper (>= 9), $(echo ${builddepends} | sed 's| |, |g')
Standards-Version: 3.9.6
Homepage: ${homepage}

EOF
  for n in $(seq 0 $((${pkgcount} - 1))); do
    echo "Package: ${packages[$n]}" >> control

    test -z "${sections[*]}" -o "${sections[$n]}" = 0 || \
      echo "Section: ${sections[$n]}" >> control

    if [ -z "${architectures[*]}" -o "${architectures[$n]}" = "0" ]; then
      arches="any"
    else
      arches="${architectures[$n]}"
    fi
    echo "Architecture: ${arches}" >> control

    echo "Depends: \${shlibs:Depends}, \${misc:Depends}," >> control
    test -z "${depends[*]}" -o "${depends[$n]}" = 0 || \
      echo " ${depends[$n]}" >> control

    echo "Pre-Depends: \${misc:Pre-Depends}" >> control

    test -z "${recommends[*]}" -o "${recommends[$n]}" = 0 || \
      echo "Recommends: ${recommends[$n]}" >> control

    test -z "${suggests[*]}"} -o "${suggests[$n]}" = 0 || \
      echo "Suggests: ${suggests[$n]}" >> control

    test -z "${provides[*]}" -o "${provides[$n]}" = 0 || \
      echo "Provides: ${provides[$n]}" >> control

    test -z "${replaces[*]}" -o "${replaces[$n]}" = 0 || \
      echo "Replaces: ${replaces[$n]}" >> control

    test -z "${brakes[*]}" -o "${brakes[$n]}" = 0 || \
      echo "Brakes: ${brakes[$n]}" >> control

    echo "Description: ${pkgdesc}" >> control
    echo "${pkgdesc_long}" | fold -s -w 79 | sed 's|^| |g; s|^ $| .|g; s| $||g' >> control
    echo "" >> control
  done
  if [ ${debugpkg} != 0 ]; then
    cat <<EOF >> control
Package: ${debugpkg}
Priority: extra
Section: debug
Architecture: any
Depends: \${misc:Depends},
EOF
    dbgcount=$(echo ${debugging[*]} | wc -w)
    for n in $(seq 0 $(($dbgcount - 1))); do
      echo " ${debugging[$n]} (= \${binary:Version})," >> control
    done
    echo "Description: ${pkgdesc} (debug)" >> control
    echo "${pkgdesc_long}" | fold -s -w 79 | sed 's|^| |g; s|^ $| .|g; s| $||g' >> control
    cat <<EOF >> control
 .
 This package provides debug symbols for ${source}.

EOF
  fi

  # copyright
  cat <<EOF > copyright
Copyright (c) ${copyright}

Homepage: ${homepage}
Source: ${srcurl}

This software was released under the following license(s):
${license}

On Debian GNU/Linux systems, the complete text of the Apache License Version 2.0,
the Artistic License and GNU General Public Licenses can be found
in the following text files:
/usr/share/common-licenses/GPL-2
/usr/share/common-licenses/GPL-3
/usr/share/common-licenses/LGPL-2
/usr/share/common-licenses/LGPL-2.1
/usr/share/common-licenses/LGPL-3
/usr/share/common-licenses/GFDL-1.2
/usr/share/common-licenses/GFDL-1.3
/usr/share/common-licenses/Apache-2.0
/usr/share/common-licenses/Artistic
EOF

  # rules
  cat <<EOF > rules
#!/usr/bin/make -f

#export DH_VERBOSE=1

PKGCOUNT=${pkgcount}
ifeq (\$(PKGCOUNT),1)
DHDEST=${packages[0]}
else
DHDEST=tmp
endif


%:
	dh \$@

override_dh_clean:
override_dh_auto_clean:
override_dh_auto_configure:
override_dh_auto_build:
override_dh_auto_test:
override_dh_auto_install:

override_dh_install:
	[ ! -d "\$(CURDIR)/${installsrc}" ] || mv "\$(CURDIR)/${installsrc}" "\$(CURDIR)/debian/\$(DHDEST)"
	dh_install

override_dh_installdocs:
	dh_installdocs -A ${docs}

override_dh_installchangelogs:
	dh_installchangelogs -A ${changelog}

override_dh_shlibdeps:
	dh_shlibdeps -l/usr/lib/${DEB_HOST_MULTIARCH}/mesa/:/lib/${DEB_HOST_MULTIARCH}:/usr/lib/${DEB_HOST_MULTIARCH}:${SHLIBDEPS_LIBRARY_PATH}
	[ ! -x /usr/bin/dh_clideps ] || dh_clideps
	[ ! -x /usr/bin/dh_sphinxdoc ] || dh_sphinxdoc

override_dh_gencontrol:
	@echo
	@echo '   IGNORE WARNINGS ABOUT UNKNOWN SUBSTITUION VARIABLES!'
	@echo
	dh_gencontrol
EOF
  chmod +x rules
  if [ ${debugpkg} != 0 ]; then
    cat <<EOF >> rules

override_dh_strip:
	dh_strip $(for p in ${debugging}; do printf -- "-p${p} "; done) --dbg-package=${debugpkg}
	dh_strip --remaining-packages
EOF
  fi

  cd ..
}


install_builddeps
prepare
cd "${srcdir}"
clean
build
gen_debian
package

LANG=C
LANGUAGE=C
LC_ALL=C
dpkg-buildpackage -b -us -uc 2>&1 | tee build.log

if [ -x /usr/bin/lintian ]; then
  packages="$(find "${basedir}" -maxdepth 1 -type f -name *.deb)"
  if [ -n "${packages}" ]; then
    echo -e "\n\nRunning Lintian checks...\n"
    for f in ${packages} ; do
      echo "${f}:"
      lintian "${f}"
      echo
    done
  fi
fi

echo -e "\nHINT: You can remove installed build-dependencies with \`sudo apt-get autoremove --purge'"



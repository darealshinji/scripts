#!/bin/sh

# Copyright (c) 2015-2016, djcj <djcj@gmx.de>
#
# helper script to install Steam into the user directory, including menu entries
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

url=http://repo.steampowered.com/steam/archive/precise/steam_latest.tar.gz
bsdir="$HOME/.local/share/steam-bootstrap"
local_apps="$HOME/.local/share/applications"
local_icons="$HOME/.local/share/icons/hicolor"
desktop_path="$(xdg-user-dir DESKTOP)"
orig="$(cd `dirname "$0"` && pwd)/$(basename "$0")"

# check if zenity is present
zenity --version 2>/dev/null >/dev/null
if [ $? != 0 ]; then
  echo "Steam requires zenity to be installed on your system!"
  exit 1
fi

set -e

if [ ! -x "$bsdir/steam/steam" ]; then
  rm -rf "$bsdir"
  mkdir -p "$bsdir"
  cd "$bsdir"
  cp "$orig" bootstrap.sh
  
  # check if we can run 32 bit programs
  cat <<_BASE64 | base64 -d | bunzip2 > test32bit
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
6/xdyRThQkDA+9YU
_BASE64
  # this base64 code was generated with the following command:
  # echo "main(){return 0;};" | gcc -m32 -O3 -s -x c - -o test32bit && bzip2 test32bit -c | base64
  chmod a+x test32bit
  set +e
  ldd test32bit 2>/dev/null >/dev/null
  if [ $? != 0 ]; then
    zenity --error --text="No 32 bit dynamic linker was found on this system!"
    exit 1
  fi
  rm -f test32bit
  set -e

  # download
  wget $url 2>&1 | sed -u 's/^[a-zA-Z\-].*//; s/.* \{1,2\}\([0-9]\{1,3\}\)%.*/\1\n#Downloading... \1%/; s/^20[0-9][0-9].*/#Done./' | \
  zenity --progress \
         --title="Downloading Steam" \
         --text "Wait a few seconds until the donwload is finished ..." \
         --auto-close

  tar xf steam_latest.tar.gz

  chmod a+x steam/steam

  # menu entry
  mkdir -p "$local_apps"
  sed "s|/usr/bin/steam|\"$bsdir/bootstrap.sh\"|" steam/steam.desktop > "$local_apps/steam.desktop"

  # desktop "shortcuts"
  if [ -d "$desktop_path" ]; then
    cp -f "$local_apps/steam.desktop" "$desktop_path"
    chmod a+x "$desktop_path/steam.desktop"
    cat <<EOF> "$desktop_path/uninstall-steam.desktop"
[Desktop Entry]
Name=Uninstall Steam
Comment=Remove Steam from your computer
Exec="$bsdir/uninstall-steam.sh" %U
Icon=steam
Terminal=false
Type=Application
Categories=Network;FileTransfer;Game;
EOF
  chmod a+x "$desktop_path/uninstall-steam.desktop"
  fi

  # icons
  for n in 16 24 32 48 256; do
    mkdir -p "$local_icons/${n}x${n}/apps"
    cp -f steam/icons/$n/steam.png "$local_icons/${n}x${n}/apps/"
  done
  cp -f steam/icons/48/steam_tray_mono.png "$local_icons/48x48/apps/"

  # uninstall script
  cat <<_UNINSTALL_STEAM_SH> uninstall-steam.sh
#!/bin/sh

zenity --version 2>/dev/null >/dev/null
if [ \$? != 0 ]; then
  echo "This script requires zenity to be installed on your system!"
  exit 1
fi

remove_steam_bootstrap=no
remove_steam_runtime=no

zenity --question --text="Do you want to remove the Steam menu entries and desktop shortcuts?"
if [ \$? = 0 ]; then
  remove_steam_bootstrap=yes
fi
zenity --question --text="Do you also want to remove your local Steam installation \n\
from \"$HOME/.local/share/Steam\"?\n\
This will remove all your games that have been installed with Steam."
if [ \$? = 0 ]; then
  remove_steam_runtime=yes
fi

if [ \$remove_steam_runtime = yes ]; then
   rt1="$HOME/.steam"
   rt2="$HOME/.local/share/Steam"
fi

if [ \$remove_steam_bootstrap = yes ]; then
  ( for n in 16 24 32 48 256; do
     rm -f "$local_icons/\${n}x\${n}/apps/steam.png"
   done
   rm -f "$local_icons/48x48/apps/steam_tray_mono.png"
   rm -f "$local_apps/steam.desktop"
   rm -f "$desktop_path/steam.desktop"
   rm -f "$desktop_path/uninstall-steam.desktop"
   rm -f "$HOME/.uninstall-steam.sh"
   rm -rf "$bsdir" "\$rt1" "\$rt2" ) | \
  zenity --progress \
         --pulsate \
         --auto-close \
         --no-cancel \
         --text="Removing Steam"
fi
_UNINSTALL_STEAM_SH
  chmod a+x uninstall-steam.sh
  ln -fs "$bsdir/uninstall-steam.sh" "$HOME/.uninstall-steam.sh"
fi

"$bsdir/steam/steam" $@


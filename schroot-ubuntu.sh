#!/bin/bash
# little helper script to make it easier to
# handle schroots on Ubuntu

set -e

mirror=http://archive.ubuntu.com/ubuntu/
#mirror=http://us.archive.ubuntu.com/ubuntu/
#mirror=http://ftp.us.debian.org/debian
repos="main restricted universe multiverse"
pfx=/opt/chroot
extra_packages="build-essential nano bash-completion command-not-found software-properties-common"

if [ -z $1 ] || [ -z $2 ]; then
  echo "usage: $0 codename username [i386]"
  exit 1
fi

codename=$1
users=$2

if [ "$(uname -m)" != "x86_64" ]; then
  echo "error: script was made for x86_64 (aka amd64) architectures"
  exit 1
fi

if [ $EUID -ne 0 ]; then
  echo "error: run as root or sudo!"
  exit 1
fi

if [ "x$3" = "xi386" ]; then
  id=${codename}32
  arch=i386
else
  id=$codename
  arch=amd64
fi

if [ -d $pfx/$id ]; then
  echo " --- chroot already present at \`$pfx/$id'"
  echo " --- stopping now"
  exit 0
elif [[ ! -d $pfx/$id && -f $pfx/$id.tgz ]]; then
  echo " --- extracting backup tarball"
  cd $pfx && tar xf $id.tgz
  echo " --- done"
  exit 0
fi

echo " --- begin bootstrapping Ubuntu $codename $arch"
mkdir -p $pfx
debootstrap --arch $arch $codename $pfx/$id $mirror

sed -i -e "s|^\[$id\]|[${id}_old]|g" /etc/schroot/schroot.conf
cat <<EOL>> /etc/schroot/schroot.conf

[$id]
description=Ubuntu $codename $arch
directory=$pfx/$id
users=$users
type=directory
profile=desktop
EOL
if [ $arch = i386 ]; then
  echo "personality=linux32" >> /etc/schroot/schroot.conf
fi
cat <<EOL>> /etc/schroot/schroot.conf
preserve-environment=true

EOL

schroot -c $id -- cp -f /etc/apt/sources.list /etc/apt/sources.list.backup
schroot -c $id -- printf "deb $mirror $codename $repos\ndeb $mirror ${codename}-updates $repos\ndeb $mirror ${codename}-security $repos\n" | \
  schroot -c $id -- tee /etc/apt/sources.list
echo "---- $id: update packages"
schroot -c $id -- apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade
echo "---- $id: install extra packages"
schroot -c $id -- apt-get -y install $extra_packages
schroot -c $id -- apt-get -y clean

schroot -c $id -- locale-gen en_US.UTF-8
schroot -c $id -- locale-gen en_GB.UTF-8
schroot -c $id -- locale-gen de_DE.UTF-8

echo "---- $id: update packages"
schroot -c $id -- apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade

cd $pfx
echo "---- $id: create backup tarball"
tar cfz $id.tgz $id
echo "---- $id: done"


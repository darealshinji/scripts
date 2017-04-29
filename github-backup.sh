#!/bin/bash
set -e
set -x

shopt -u dotglob

s=3
user=darealshinji

if [ -z "$1" ]; then
  repos=$(curl -s https://api.github.com/users/$user/repos?per_page=100 | grep '"name":' | cut -d '"' -f4)
else
  repos="$@"
fi

for repo in $repos ; do
  sleep $s
  if [ -e $repo/data/.git ] ; then
    git -C $repo/data pull origin
    rm -rf $repo/data/*
  else
    rm -rf $repo
    mkdir -p $repo
    cd $repo
    git clone https://github.com/$user/$repo
    mv $repo data
    rm -rf data/*
    test -d data/.git
    cd -
  fi
  sleep $s
  rm -rf $repo/releases/continuous
  urls=$(curl -s https://api.github.com/repos/$user/$repo/releases | grep 'browser_download_url' | cut -d '"' -f4)
  if [ -n "$urls" ] ; then
    for url in $urls ; do
      dir="$repo/releases/$(basename $(dirname $url))"
      mkdir -p "$dir"
      file=$(basename $url)
      if [ ! -e "$dir/$file" ] ; then
        sleep $s
        wget -c -O "$dir/$file" $url
      fi
    done
  fi
done


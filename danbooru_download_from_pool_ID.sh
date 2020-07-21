#!/bin/sh -e

if [ "x$1" = "x" ]; then
  echo "usage: $0 POOLID"
  exit 1
fi

idList=$(wget -q -O- https://danbooru.donmai.us/pools/${1}.json?only=post_ids | grep -o '"post_ids":\[[0-9,]*\]' | tr -c -d '0-9,' | tr ',' ' ')

n=0

for id in $idList ; do
  url=$(wget -O- -q https://danbooru.donmai.us/posts/${id}.json | grep -o '"file_url":".*"' | cut -d '"' -f4)

  if [ "x$url" != "x" ]; then
    #echo "wget -c -q -O ${id}-$(basename $url) $url"
    out="${id}-$(basename $url)"
    echo "$url  ->  $out"
    wget -c -q -O $out $url
    n=$((n + 1))
  fi

  if [ $n -ge 10 ]; then
    #echo "sleep 3"
    sleep 3
    n=0
  fi
done

#!/bin/sh

# automatically calls the highest available automake/aclocal version

# http://packages.ubuntu.com/search?suite=all&searchon=names&keywords=automake
# https://packages.debian.org/search?keywords=automake&searchon=names&suite=all&section=all

if [ "$(basename "$0")" = "aclocal" ]; then
	cmd="aclocal"
else
	cmd="automake"
fi

for n in $(seq -f 1.%.f 1 20); do
	if [ -x /usr/bin/${cmd}-${n} ]; then
		avail="$avail $n"
	fi
done

ver=$(echo "$avail" | tr ' ' '\n' | sort -V | tail -n1)

/usr/bin/${cmd}-${ver} $*


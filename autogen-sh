#!/bin/sh

autogen () {
  # autogen command(s)
  mkdir -p build-aux
  autoreconf -i -f
}
cleanscript="autogen-cleanup.sh"

find . > .autogen_sh_before
autogen
find . > .autogen_sh_after
diff -u .autogen_sh_before .autogen_sh_after | grep '^+\./' | sed 's|^+||g' | \
	grep -v '^\.\/git\/' | \
	grep -v '^\.\/hg\/' | \
	grep -v '^\.\/svn\/' | \
	grep -v '^\.\/bzr\/' | \
	grep -v '^\.\/\.autogen_sh_' > .autogen_sh_files

cat <<EOF> $cleanscript
#!/bin/sh
if [ -f Makefile ] || [ -f GNUmakefile ]; then
	(make maintainer-clean 2>/dev/null || 
	 make distclean 2>/dev/null || 
	 make clean 2>/dev/null) || true
fi
set -v
EOF

chmod a+x $cleanscript

for f in $(tac .autogen_sh_files); do
	if [ -d $f ]; then
		echo "rmdir $f 2>/dev/null || true" >> $cleanscript
	else
		echo "rm -f $f" >> $cleanscript
	fi
done
echo "rm -f $cleanscript" >> $cleanscript

rm -f .autogen_sh_before .autogen_sh_after .autogen_sh_files


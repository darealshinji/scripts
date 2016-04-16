#!/bin/sh

# Show the highest versions for the symbols GLIBCXX (libstdc++), CXXABI, GLIBC
# and GCC (libgcc_s) listed in the ELF symbol table and dynamic symbol table.
# Useful to find out compatibilities, especially for libstdc++.

LANG=C

glibcxx=$(objdump -t "$1" | sed -n 's/.*@@GLIBCXX_//p' | grep -e '^[0-9]' | cut -d ' ' -f1 | tr -d ')' | sort -uV | tail -1)
cxxabi=$(objdump -t "$1"  | sed -n 's/.*@@CXXABI_//p'  | grep -e '^[0-9]' | cut -d ' ' -f1 | tr -d ')' | sort -uV | tail -1)
glibc=$(objdump -t "$1"   | sed -n 's/.*@@GLIBC_//p'   | grep -e '^[0-9]' | cut -d ' ' -f1 | tr -d ')' | sort -uV | tail -1)
gcc=$(objdump -t "$1"     | sed -n 's/.*@@GCC_//p'     | grep -e '^[0-9]' | cut -d ' ' -f1 | tr -d ')' | sort -uV | tail -1)

if objdump -T "$1" 2>/dev/null >/dev/null ; then
  glibcxx_d=$(objdump -T "$1" | sed -n 's/.*GLIBCXX_//p' | grep -e '^[0-9]' | cut -d ' ' -f1 | tr -d ')' | sort -uV | tail -1)
  cxxabi_d=$(objdump -T "$1"  | sed -n 's/.*CXXABI_//p'  | grep -e '^[0-9]' | cut -d ' ' -f1 | tr -d ')' | sort -uV | tail -1)
  glibc_d=$(objdump -T "$1"   | sed -n 's/.*GLIBC_//p'   | grep -e '^[0-9]' | cut -d ' ' -f1 | tr -d ')' | sort -uV | tail -1)
  gcc_d=$(objdump -T "$1"     | sed -n 's/.*GCC_//p'     | grep -e '^[0-9]' | cut -d ' ' -f1 | tr -d ')' | sort -uV | tail -1)
  dynamic="yes"
else
  objdump -T "$1" >/dev/null
  dynamic="no"
fi

cat <<EOL

symbol table
 GLIBCXX: $glibcxx
 CXXABI: $cxxabi
 GLIBC: $glibc
 GCC: $gcc

EOL

if [ "$dynamic" = "yes" ]; then
  cat <<EOL
dynamic symbol table
 GLIBCXX: $glibcxx_d
 CXXABI: $cxxabi_d
 GLIBC: $glibc_d
 GCC: $gcc_d

EOL
fi

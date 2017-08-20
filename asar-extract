#!/bin/bash

# The MIT License (MIT)
#
# Copyright (C) 2017, djcj <djcj@gmx.de>
#
# JSON parsing functions were taken from https://git.io/v5eN9 and are
# Copyright (C) 2011-2017, Dominic Tarr <dominic.tarr@gmail.com>
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

### begin of JSON.sh ###

throw() {
  echo "$*" >&2
  exit 1
}

BRIEF=1
LEAFONLY=1
PRUNE=1
NO_HEAD=0
NORMALIZE_SOLIDUS=1

awk_egrep () {
  local pattern_string=$1

  gawk '{
    while ($0) {
      start=match($0, pattern);
      token=substr($0, start, RLENGTH);
      print token;
      $0=substr($0, start+RLENGTH);
    }
  }' pattern="$pattern_string"
}

tokenize () {
  local GREP
  local ESCAPE
  local CHAR

  if echo "test string" | egrep -ao --color=never "test" >/dev/null 2>&1
  then
    GREP='egrep -ao --color=never'
  else
    GREP='egrep -ao'
  fi

  if echo "test string" | egrep -o "test" >/dev/null 2>&1
  then
    ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    CHAR='[^[:cntrl:]"\\]'
  else
    GREP=awk_egrep
    ESCAPE='(\\\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    CHAR='[^[:cntrl:]"\\\\]'
  fi

  local STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
  local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
  local KEYWORD='null|false|true'
  local SPACE='[[:space:]]+'

  # Force zsh to expand $A into multiple words
  local is_wordsplit_disabled=$(unsetopt 2>/dev/null | grep -c '^shwordsplit$')
  if [ $is_wordsplit_disabled != 0 ]; then setopt shwordsplit; fi
  $GREP "$STRING|$NUMBER|$KEYWORD|$SPACE|." | egrep -v "^$SPACE$"
  if [ $is_wordsplit_disabled != 0 ]; then unsetopt shwordsplit; fi
}

parse_array () {
  local index=0
  local ary=''
  read -r token
  case "$token" in
    ']') ;;
    *)
      while :
      do
        parse_value "$1" "$index"
        index=$((index+1))
        ary="$ary""$value" 
        read -r token
        case "$token" in
          ']') break ;;
          ',') ary="$ary," ;;
          *) throw "EXPECTED , or ] GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
      ;;
  esac
  [ "$BRIEF" -eq 0 ] && value=$(printf '[%s]' "$ary") || value=
  :
}

parse_object () {
  local key
  local obj=''
  read -r token
  case "$token" in
    '}') ;;
    *)
      while :
      do
        case "$token" in
          '"'*'"') key=$token ;;
          *) throw "EXPECTED string GOT ${token:-EOF}" ;;
        esac
        read -r token
        case "$token" in
          ':') ;;
          *) throw "EXPECTED : GOT ${token:-EOF}" ;;
        esac
        read -r token
        parse_value "$1" "$key"
        obj="$obj$key:$value"        
        read -r token
        case "$token" in
          '}') break ;;
          ',') obj="$obj," ;;
          *) throw "EXPECTED , or } GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
    ;;
  esac
  [ "$BRIEF" -eq 0 ] && value=$(printf '{%s}' "$obj") || value=
  :
}

parse_value () {
  local jpath="${1:+$1,}$2" isleaf=0 isempty=0 print=0
  case "$token" in
    '{') parse_object "$jpath" ;;
    '[') parse_array  "$jpath" ;;
    # At this point, the only valid single-character tokens are digits.
    ''|[!0-9]) throw "EXPECTED value GOT ${token:-EOF}" ;;
    *) value=$token
       # if asked, replace solidus ("\/") in json strings with normalized value: "/"
       [ "$NORMALIZE_SOLIDUS" -eq 1 ] && value=$(echo "$value" | sed 's#\\/#/#g')
       isleaf=1
       [ "$value" = '""' ] && isempty=1
       ;;
  esac
  [ "$value" = '' ] && return
  [ "$NO_HEAD" -eq 1 ] && [ -z "$jpath" ] && return

  [ "$LEAFONLY" -eq 0 ] && [ "$PRUNE" -eq 0 ] && print=1
  [ "$LEAFONLY" -eq 1 ] && [ "$isleaf" -eq 1 ] && [ $PRUNE -eq 0 ] && print=1
  [ "$LEAFONLY" -eq 0 ] && [ "$PRUNE" -eq 1 ] && [ "$isempty" -eq 0 ] && print=1
  [ "$LEAFONLY" -eq 1 ] && [ "$isleaf" -eq 1 ] && \
    [ $PRUNE -eq 1 ] && [ $isempty -eq 0 ] && print=1
  [ "$print" -eq 1 ] && printf "[%s]\t%s\n" "$jpath" "$value"
  :
}

parse () {
  read -r token
  parse_value
  read -r token
  case "$token" in
    '') ;;
    *) throw "EXPECTED EOF GOT $token" ;;
  esac
}

### end of JSON.sh ###


save_file () {
  mkdir -p "$1/$(dirname "$file")"
  echo "saving \"$file\""
  tail -c+$(($header_size + $offset + 2)) "$archive" | head -c$size > "$1/$file"
}

print_usage () {
  cat <<EOL

  Usage: $0 [options] [command]

  List and extract asar archive files

  Options:

    -h, --help     output usage information

  Commands:

    list|l <archive>                      list files of asar archive
    extract-file|ef <archive> <filename>  extract one file from archive
    extract|e <archive> <dest>            extract archive

EOL
  exit $1
}

arg1="$1"
archive="$2"
dest="$3"
command="extract"

case "$arg1" in
  "list"|"l")
    command="list"
    ;;
  "extract-file"|"ef")
    command="extract-file"
    [ -n "$dest" ] || print_usage 1
    ;;
  "extract"|"e")
    command="extract"
    [ -n "$dest" ] || print_usage 1
    ;;
  "--help"|"-h")
    print_usage 0
    ;;
  *)
    print_usage 1
    ;;
esac

if [ ! -e "$archive" ]; then
  print_usage 1
fi

# this is used to calculate the header size
val=$(tail -c+4 "$archive" | head -c4 | od -An -tu2 --endian=big)
header_size=$(( $(echo $val | awk '{print $1}') + $(echo $val | awk '{print $2}') + 7 ))

# file index (JSON data)
index=$(head -c$header_size "$archive" | tail -c+16 | tr -d '\0' | tokenize | parse)

count=$(echo "$index" | grep ',"offset"]' | wc -l)
files=$(echo "$index" | sed -n 's|,"offset"].*||p' | sed -e 's|","files","|/|g; s|"$||; s|^\["files","||')
if [ "$command" != "list" ]; then
  offsets=$(echo "$index" | sed -n 's|.*,"offset"]\t||p' | tr -d '"')
  sizes=$(echo "$index" | sed -n 's|.*,"size"]\t||p')
fi

for n in $(seq 1 $count); do
  file=$(echo "$files" | head -$n | tail -1)
  if [ "$command" = "list" ]; then
    echo "$file"
  else
    offset=$(echo "$offsets" | head -$n | tail -1)
    size=$(echo "$sizes" | head -$n | tail -1)
    if [ "$command" = "extract-file" ]; then
      if [ "$file" = "$dest" ]; then
        save_file .
        exit $?
      fi
    else
      save_file "$dest"
    fi
  fi
done


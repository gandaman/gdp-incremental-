#!/bin/sh

# (C) 2017 Gunnar Andersson
# LICENSE: MPLv2

usage() {
  local name=$(basename "$0")
  echo "Usage: $name <target> <git-ref>"
  echo "Ref can be a commit-hash, branch, tag, etc."
  echo "target is a valid build target (hardware) for GDP"
  exit 1
}

# This is some trickery, but quite useful
deref() { eval echo \$$1 ; }

D=$(dirname "$0")
cd "$D"
MYDIR="$PWD"

for d in base targets/*/{base,source,build} ; do
  cd "$d"
  echo "------------- $d -----------"
  echo "+ docker build -t gdpbuild/$d"
  docker build -t gdpbuild/$d .
  echo
  cd "$MYDIR"
done


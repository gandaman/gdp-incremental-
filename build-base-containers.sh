#!/bin/sh

# (C) 2017 Gunnar Andersson
# LICENSE: MPLv2

# Build base containers, i.e. those that do not need to know which commit
# to build

D=$(dirname "$0")
cd "$D"
MYDIR="$PWD"

# Pass -q for quiet builds
QFLAG="$1"

d=docker/base
cd "$d"
echo "------------- $d -----------"
docker build -t gdpbuild/base .
cd "$MYDIR"

for d in docker/targets/*/{base,source_base} ; do
  cd "$d"
  tag="gdpbuild/$(basename $(readlink -f $PWD/..))_$(basename $PWD)"
  echo "------------- $d -> $tag -----------"
  docker build $QFLAG -t $tag .
  if [ $? -ne 0 ] ; then
    echo "FAILED"
    failed_list="$failed_list $tag"
  fi
  echo
  cd "$MYDIR"
done

if [ -n "$failed_list" ] ; then
  echo "Failed builds:"
  for x in $failed_list ; do
    echo $x
  done
fi


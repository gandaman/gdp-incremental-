#!/bin/sh

# (C) 2017 Gunnar Andersson
# LICENSE: MPLv2

D=$(dirname "$0")
cd "$D"
MYDIR="$PWD"

d=docker/base
cd "$d"
echo "------------- $d -----------"
docker build -t gdpbuild/base .
cd "$MYDIR"

for d in docker/targets/*/{base,source,build} ; do
  cd "$d"
  tag="gdpbuild/$(basename $(readlink -f $PWD/..))_$(basename $PWD)"
  echo "------------- $d -----------"
  docker build -t $tag .
  echo
  cd "$MYDIR"
done


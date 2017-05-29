#!/bin/sh -e

# (C) 2017 Gunnar Andersson
# LICENSE: MPLv2

PULL_ENABLED=false
ENVFILE="./environment"

usage() {
  local name=$(basename "$0")
  echo "Usage: $name <target> <git-ref>"
  echo "Ref can be a commit-hash, branch, tag, etc."
  echo "target is a valid build target (hardware) for GDP"
  exit 1
}

# This is some trickery, but quite useful
deref() { eval echo \$$1 ; }

# Since we use stdout for function output we must
# use STDERR here
logline() {
   echo "$@" 1>&2
}
log() {
   echo -n "$@" 1>&2
}

image_exists() {
  docker images | fgrep -q "$1"
}

pull_image() {
  if $PULL_ENABLED ; then
    logline "Pulling image $1 from repository"
    docker pull "$1" || log "...could not pull" 
    return $?
  else
    false
  fi
}

# FIXME this is totally broken
# write logic to go from imagename -> Dockerfile
build_image() {
  img=$1
  hash=$2  # Empty for some images
  dir=$(echo "$img" | sed 's!gdpbuild/!!')
  target=$(echo "$dir" | cut -d_ -f 1)
  type=$(echo "$dir" | cut -d_ -f 2)
  if [ -z "$hash" ] ; then
    dir="docker/targets/$target/$type"
  else
    dir="docker/targets/$target/${type}_$hash"
  fi
  if [ -d "$dir" ] ; then
    cd "$dir"
    logline ""
    logline "Building image $1 using $dir/Dockerfile"
    # For some builds, if $hash ($REF) is empty then that's OK
    set -x
    docker build --build-arg=REF=$hash -t "$1" .
    set +x
    return $?
  else
    #echo "*** FAILED finding dir $dir"
    false
  fi
}

# Get the docker image name based on parameters
image_name() {
  local target="$1" type="$2" hash="$3" h=""
  [ -n "$hash" ] && h="_$hash"
  [ -n "$type" ] && t="_$type"
  echo "gdpbuild/${target}${t}${h}"
}

base_image_name() {
  image_name $1 base
}

source_base_image_name() {
  image_name $1 source_base
}

source_image_name() {
  image_name $1 source $2
}

builtonce_image_name() {
  image_name $1 builtonce $2
}

find_image() {
  # (ref argument is used for only some)
  local wanted="$1" found="" ref="$2"
  logline ""
  logline "Looking for $wanted..."
  if image_exists "$wanted" ; then
    log "...found"
    found="$wanted"
    return 0
  else
    log "...does not exist locally"
  fi

  if pull_image "$wanted" ; then
    log "...pulled OK"
    chosen_image="$wanted"
    return 0
  else
    log "...no pull, or failed pull"
  fi

  if build_image "$wanted" $ref; then
    log "...built OK"
    chosen_image="$wanted"
    return 0
  else
    log "...could not build"
    chosen_image=""
    return 1
  fi
}

find_image_from_history() {
  local target="$1" ref="$2" builtonce_with_hash with_hash history found

  # h = the history hash
  # ref = the new hash, the one to build
  history=$(git rev-list $ref | cut -c 1-10)
  for h in $history ; do
    logline ""
    logline "Trying $h"
    builtonce_with_hash=$(image_name $target builtonce $h)
    with_hash=$(image_name $target "" $h)
    if find_image $builtonce_with_hash $ref; then
      found=$builtonce_with_hash
      logline "Found builtonce with hash: $found"
      break
    elif find_image $with_hash $ref; then
      found=$with_hash
      logline "Found with hash: $found"
      break
    else
      logline ""
      logline "...giving up for $h"
      found=""
    fi
  done

  chosen_image="$found"
  if [ -n "$chosen_image" ]; then
    true
  else
    false
  fi
}

# The logic to find the most appropriate image.  
# We try in this preferred order.  If one fails, try the next step:
# - an image matching the commit we want to build (i.e. we are done)
# - an image that has built some commit found in the immediate git history.
# - an image that has at least downloaded the sources.
# - an image that is at least set up for the target.
# - an image that is set up for yocto build and with the basic project
# - easy-build base for yocto builds

determine_build_image() {
  local target="$1" ref="$2" source_base_img source_img builtonce_img img

  # Image names, in case we need them
  this_image=$(image_name $target "" $ref)
  source_base_img=$(source_base_image_name $target)
  source_img=$(source_image_name $target $ref) #unlikely to exist for ref?
  builtonce_img=$(builtonce_image_name $target $ref) #unlikely to exist?
  base_img=$(base_image_name $target)

  logline "Looking back in history for most recent image"

  # find_image this_image?  or pull_image?
  if pull_image "$this_image" ; then
    log "...already built - pulled OK"
    chosen_image="$this_image"
    return 0
  else
    log "...no pull, or failed pull"
  fi

  # either <hash> or builtonce_<hash>
  # NOTE $ref is the new starting $ref
  if find_image_from_history $target $ref ; then
    logline "...found image in history."
    # (returns $chosen_image)
    return 0
  else
    log "...not in history"
  fi

#  if find_image $builtonce_img ; then
#    logline "...found builtonce image"
#    chosen_image="$builtonce_img"
#    return 0
#  else
#    log "...no builtonce img"
#  fi

  if find_image $source_img ; then
    logline "...found source image"
    chosen_image="$source_img"
    return 0
  else
    log "...no source img"
  fi

  if find_image $source_base_img ; then
    logline "...found source_base image"
    chosen_image="$source_base_img"
    return 0
  else
    log "...no source img"
  fi

  if find_image $base_img ; then
    logline "...found base image"
    chosen_image="$base_img"
    return 0
  else
    log "...no base img"
  fi

  if find_image gmacario/build-yocto ; then
    logline "...found easy-build/build-yocto image"
    chosen_image="gmacario/build-yocto"
    echo "FIXME - SHOULD RUN docker build here instead"
    return 0
  else
    logline "...no build-yocto img"
    chosen_image=
    return 1
  fi
}

# --- MAIN PROGRAM ---
[ $# -lt 2 ] && usage
target="$1"
ref="$2"

if determine_build_image $target $ref ; then
  logline "Chosen image is $chosen_image"
else
  logline "FATAL:  Found no appropriate image"
  exit 1
fi

logline "Found an image.  Starting build based on $chosen_image"

logline "Preparing env file: "
cat <<EOT >"$ENVFILE"
TARGET=$target
COMMIT=$ref
REUSE_STANDARD_DL_DIR=false
REUSE_STANDARD_SSTATE_DIR=false
BRANCH=$BRANCH
TAG=$TAG
RELEASE=$RELEASE
BUILD_SDK=$BUILD_SDK
SGX_DRIVERS=$SGX_DRIVERS
SGX_GEN_3_DRIVERS=$SGX_GEN_3_DRIVERS
DL_DIR=$DL_DIR
SSTATE_DIR=$DL_DIR
RM_WORK=$RM_WORK
EOT

# Finally find and add any LAYER_xxx_FOO variables
for var in $(env | grep -P 'LAYER_\w+(BRANCH|COMMIT|TAG|FORK)' | sed 's/=.*//') ; do
  echo "$var=$(deref $var)" >>"$ENVFILE"
done

cat "$ENVFILE"

logline "Running build in docker"
set -x
id=$(docker run -d -ti --env-file "$ENVFILE" $chosen_image scripts/ci-build.sh CI_FLAG)
set +x
docker attach $id
docker_result=$?

chosen_image_without_slash="$(echo $chosen_image | sed 's!/!_!g')"
timestamp=$(date +"%Y-%m-%d_%H%M%S")

if [ $docker_result -eq 0 ] ; then
  echo "Result is OK."
  new_image_tag="gdpbuild/${target}_${ref}"
  new_image_tag_without_slash="gdpbuild_${target}_${ref}"
  logname="logs_${timestamp}_from_${chosen_image_without_slash}_to_${new_image_tag_without_slash}.txt"
else
  echo "Result is FAIL : $docker_result"
  logname="logs_${timestamp}_from_${chosen_image_without_slash}_FAILED.txt"
fi

echo "Saving logs from docker run -> $logname.gz"
docker logs $id >"$logname"
gzip "$logname"

# Keep incremental image if build was successful
if [ $docker_result -eq 0 ] ; then
  echo "Storing image from successful build"
  newid=$(docker commit $id $new_image_tag)
fi


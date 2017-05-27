#!/bin/bash

# Script to be placed in build container as entry point

git submodule update
scripts/ci-build.sh CI_FLAG

buildresult=$?

# TODO: Run som sanity checks here

# TODO: Return pass/fail

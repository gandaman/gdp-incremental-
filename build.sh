#!/bin/bash

# Script to be placed in build container as entry point

source ./init.sh $TARGET && bitbake genivi-dev-platform

buildresult=$?

# TODO: Run som sanity checks here

# TODO: Return pass/fail

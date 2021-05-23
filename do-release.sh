#!/bin/sh

SELF=$(cd $(dirname $0) && pwd)
. "$SELF/release-utils.sh"

# Ask for release information
get_release_info

# tag
. "$SELF/create-tag.sh"

# build
# . "$SELF/release-build.sh"

# Set Java version and build docs
# 


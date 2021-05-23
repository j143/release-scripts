#!/bin/sh

SELF=$(cd $(dirname $0) && pwd)
. "$SELF/release-utils.sh"

# Ask for release information
get_release_info


# build
. "$SELF/release-build.sh" publish-snapshot

# tag
. "$SELF/create-tag.sh"

. "$SELF/release-build.sh" publish-staging
# Set Java version and build docs
# 


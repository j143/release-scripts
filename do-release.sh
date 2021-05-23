#!/bin/sh

SELF=$(cd $(dirname $0) && pwd)
. "$SELF/release-utils.sh"

# Ask for release information
get_release_info


# tag
. "$SELF/create-tag.sh"

# build
. "$SELF/release-build.sh" publish-snapshot

git checkout $RELEASE_TAG
printf "checking out $RELEASE_TAG for building artifacts"

. "$SELF/release-build.sh" publish-staging


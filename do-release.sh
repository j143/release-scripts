#!/usr/bin/env bash

SELF=$(cd $(dirname $0) && pwd)
. "$SELF/release-utils.sh"

# discussion on optional arguments
# https://stackoverflow.com/q/18414054
while getopts ":n" opt; do
  case $opt in
    n) DRY_RUN=1 ;;
    \?) error "Invalid option: $OPTARG" ;;
  esac
done

# Ask for release information
get_release_info


# tag
. "$SELF/create-tag.sh"

# build
. "$SELF/release-build.sh" publish-snapshot

git checkout $RELEASE_TAG
printf "checking out $RELEASE_TAG for building artifacts"

. "$SELF/release-build.sh" publish-staging


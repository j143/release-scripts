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
 run_silent "Creating release tag $RELEASE_TAG..." "tag.log" \
    "$SELF/create-tag.sh"

# build
# . "$SELF/release-build.sh" publish-snapshot

# git checkout $RELEASE_TAG
# printf "\n checking out $RELEASE_TAG for building artifacts \n"


printf "\n Publish Release Candidates to the Nexus Repo \n"

. "$SELF/release-build.sh" publish-release


# printf "\n Publish Release Candidates to SVN Repo \n"
. "$SELF/release-build.sh" publish-apache-staging
. "$SELF/release-build.sh" publish-staging


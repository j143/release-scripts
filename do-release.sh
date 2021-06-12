#!/usr/bin/env bash

SELF=$(cd $(dirname $0) && pwd)
. "$SELF/release-utils.sh"

# discussion on optional arguments
# https://stackoverflow.com/q/18414054
while getopts ":n:step" opt; do
  case $opt in
    n) DRY_RUN=1 ;;
    s) RELEASE_STEP=$OPTARG ;;
    \?) error "Invalid option: $OPTARG" ;;
  esac
done

# Ask for release information
get_release_info

release_step() {
  local STEP_NAME=$1
  [ -z "$RELEASE_STEP" ] || [ "$STEP_NAME" = "$RELEASE_STEP" ]
}

# tag

if release_step "tag" ; then
  run_silent "Creating release tag $RELEASE_TAG..." "tag.log" \
      "$SELF/create-tag.sh"
  
  printf "\n Synchronization of the tag would take a while..."
  printf "\n Press Enter when you've verified that the tag ($RELEASE_TAG) is available."
  read
else
  printf "\nSkipping tag creation for $RELEASE_TAG.\n"
fi

# run_silent "Publish Release Candidates to the Nexus Repo..." "publish-snapshot.log" \
#     "$SELF/release-build.sh" publish-snapshot

# git checkout $RELEASE_TAG
# printf "\n checking out $RELEASE_TAG for building artifacts \n"

# NOTE:
# The following goals publishes the artifacts to
#  1) Nexus repo at repository.apache.org
#  2) SVN repo at dist.apache.org
# 
# are to be used together.


if release_step "build" ; then
  run_silent "Publish Release Candidates to the Nexus Repo..." "publish.log" \
    "$SELF/release-build.sh" publish-release

  printf "\n Verify that the artifacts along with relevant checksums are available."
  read
else
  printf "\nSkip build and publishing to Maven repo.\n"
fi




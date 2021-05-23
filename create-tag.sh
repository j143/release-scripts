#!/bin/bash
# Create release tags and version names

# https://stackoverflow.com/q/59895
SELF=$(cd $(dirname $0) && pwd)
. "$SELF/release-utils.sh"

exit_with_usage() {
  local NAME=$(basename $0)
  cat << EOF
usage: $NAME
Tags a SystemDS release on a particular branch.
Inputs are specified with the following environment variables:
ASF_USERNAME - Apache Username
ASF_PASSWORD - Apache Password
GIT_NAME - Name to use with git
GIT_EMAIL - E-mail address to use with git
GIT_BRANCH - Git branch on which to make release
RELEASE_VERSION - Version used in pom files for release
RELEASE_TAG - Name of release tag
NEXT_VERSION - Development version after release
EOF
  exit 1
}

set -e
set -o pipefail

if [[ $@ == *"help"* ]]; then
  exit_with_usage
fi

# docs related to stty 
# https://www.ibm.com/docs/en/aix/7.2?topic=s-stty-command
if [[ -z "$ASF_PASSWORD" ]]; then
  echo 'The environment variable ASF_PASSWORD is not set. Enter the password.'
  echo
  stty -echo && printf "ASF password: " && read ASF_PASSWORD && printf '\n' && stty echo
fi

for env in ASF_USERNAME ASF_PASSWORD RELEASE_VERSION RELEASE_TAG NEXT_VERSION GIT_EMAIL GIT_NAME GIT_BRANCH; do
  if [ -z "${!env}" ]; then
    echo "$env must be set to run this script"
    exit 1
  fi
done

uriencode() { jq -nSRr --arg v "$1" '$v|@uri'; }

declare -r ENCODED_ASF_PASSWORD=$(uriencode "$ASF_PASSWORD")

# git configuration
git config user.name "$GIT_NAME"
git config user.email "$GIT_EMAIL"

printf "$RELEASE_TAG \n"
printf "$RELEASE_VERSION\n"
printf "$NEXT_VERSION"

mvn --batch-mode -DdryRun=true -Dtag=$RELEASE_TAG release:prepare \
                 -Dresume=false \
                 -DreleaseVersion=$RELEASE_VERSION \
                 -DdevelopmentVersion=$NEXT_VERSION



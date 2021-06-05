#!/usr/bin/env bash

DRY_RUN=${DRY_RUN:-0}
ASF_REPO="https://github.com/apache/systemds"
ASF_REPO_CONTENT="https://raw.githubusercontent.com/apache/systemds"

# TODO: investigate this properly
# gpg: signing failed: Inappropriate ioctl for device
# https://github.com/j143/systemds/issues/75
GPG_TTY=$(tty)
export GPG_TTY


# exit with error message
error() {
  echo "$*"
  exit 1
}

printf "Dry Run?: ${DRY_RUN} (1: true, 0: false)\n"

# Read the configuration
read_config() {
  local PROMPT="$1"
  local DEFAULT="$2"
  
  local REPLY=

  read -p "$PROMPT [$DEFAULT]: " REPLY
  local RETVAL="${REPLY:-$DEFAULT}"
  if [ -z "$RETVAL" ]; then
    error "$PROMPT must be provided"
  fi
  echo "$RETVAL"
}


# parse version number from pom.xml
# <version> tag.
parse_version() {
  grep -e '<version>.*</version>' | \
    head -n 2 | tail -n 1 | cut -d '>' -f2 | cut -d '<' -f1
}

# TODO: git clone systemds function
# https://git-scm.com/docs/git-clean
# git clean -d -f -x

# check for the tag name in git repo
check_for_tag() {
    curl -s --head --fail "$ASF_REPO/releases/tag/$1" > /dev/null
}


# get the release info including
# branch details, snapshot version
# error validation
get_release_info() {
  if [ -z "$GIT_BRANCH" ]; then
    # If not branch is specified, find the latest branch from repo
    GIT_BRANCH=$(git ls-remote --heads "$ASF_REPO" |
      grep -v refs/heads/master |
      awk '{print $2}' |
      sort -r |
      head -n 1 |
      cut -d/ -f3)
  fi

  export GIT_BRANCH=$(read_config "Branch" "$GIT_BRANCH")

  # Find the current version for the branch
  local VERSION=$(curl -s "$ASF_REPO_CONTENT/$GIT_BRANCH/pom.xml" |
    parse_version)
  
  echo "Current branch version is $VERSION."

  if [[ ! $VERSION =~ .*-SNAPSHOT ]]; then
    error "Not a SNAPSHOT version: $VERSION"
  fi

  NEXT_VERSION="$VERSION"
  RELEASE_VERSION="${VERSION/-SNAPSHOT/}"
  SHORT_VERSION=$(echo "$VERSION" | cut -d . -f 1-2)
  local REV=$(echo "$RELEASE_VERSION" | cut -d . -f 3)

  # Find out what rc is being prepared.
  # - If the current version is "x.y.0", then this is rc1 of the "x.y.0" release.
  # - If not, need to check whether the previous version has been already released or not.
  #   - If it has, then we're building rc1 of the current version.
  #   - If it has not, we're building the next RC of the previous version.
  local RC_COUNT
  if [ $REV != 0 ]; then
    local PREV_REL_REV=$((REV - 1))
    local PREV_REL_TAG="v${SHORT_VERSION}.${PREV_REL_REV}"

    if check_for_tag "$PREV_REL_TAG"; then
      RC_COUNT=1
      REV=$((REV + 1))
      NEXT_VERSION="${SHORT_VERSION}.${REV}-SNAPSHOT"
    else
      RELEASE_VERSION="${SHORT_VERSION}.${PREV_REL_REV}"
      RC_COUNT=$(git ls-remote --tags "$ASF_REPO" "v${RELEASE_VERSION}-rc*" | wc -l)
      RC_COUNT=$((RC_COUNT + 1))
    fi
  else
    REV=$((REV + 1))
    NEXT_VERSION="${SHORT_VERSION}.${REV}-SNAPSHOT"
    RC_COUNT=1
  fi

  export NEXT_VERSION
  export RELEASE_VERSION=$(read_config "Release" "$RELEASE_VERSION")

  RC_COUNT=$(read_config "RC #" "$RC_COUNT")

  # Check if the RC already exists, and if re-creating the RC, skip tag
  # creation
  RELEASE_TAG="${RELEASE_VERSION}-rc${RC_COUNT}"
  SKIP_TAG=0

  if check_for_tag "$RELEASE_TAG"; then
    read -p "$RELEASE_TAG already exists. Continue anyway [Y/n]? " ANSWER
    if [ "$ANSWER" != "Y" ]; then
      error "Exiting."
    fi
    SKIP_TAG
  fi

  export RELEASE_TAG

  GIT_REF="$RELEASE_TAG"
  
  export GIT_REF
  export PACKAGE_VERSION="$RELEASE_TAG"

  # Git configuration info
  if [ -z "$ASF_USERNAME" ]; then
    export ASF_USERNAME=$(read_config "ASF user" "$LOGNAME")
  fi

  if [ -z "$GIT_NAME" ]; then
    GIT_NAME=$(git config user.name || echo "")
    export GIT_NAME=$(read_config "Full name" "$GIT_NAME")
  fi

  export GIT_EMAIL="$ASF_USERNAME@apache.org"
  export GPG_KEY=$(read_config "GPG key" "$GIT_EMAIL")

  cat <<EOF
================
Release details:
BRANCH:     $GIT_BRANCH
VERSION:    $RELEASE_VERSION
TAG:        $RELEASE_TAG
NEXT:       $NEXT_VERSION
ASF USER:   $ASF_USERNAME
GPG KEY ID:    $GPG_KEY
FULL NAME:  $GIT_NAME
E-MAIL:     $GIT_EMAIL
================
EOF

#   read -p "Is this info correct [Y/n]? " ANSWER
  CORRECT_RELEASE_INFO=$(read_config "Is the release info correct (1 for Yes, 0 for No) ?" "$CORRECT_RELEASE_INFO")
  
  if ! CORRECT_RELEASE_INFO; then
    echo "Exiting."
    exit 1
  fi

  if [ -z "$ASF_PASSWORD" ]; then
    stty -echo && printf "ASF password: " && read ASF_PASSWORD && printf '\n' && stty echo
  fi

  if [ -z "$GPG_PASSPHRASE" ]; then
    stty -echo && printf "GPG passphrase: " && read GPG_PASSPHRASE && printf '\n' && stty echo
  fi

  export ASF_PASSWORD
  export GPG_PASSPHRASE

}

is_dry_run() {
  # By default, evaluates to false
  [[ "$DRY_RUN" = 1 ]]
}


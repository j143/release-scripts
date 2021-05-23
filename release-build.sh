#!/usr/bin/env bash

exit_with_usage() {

  cat << EOF
usage: release-details.sh <package|docs>
Create build deliverables from a commit
Top level targets are
  - package: create binary packages and commit them
             to staging repo.
  - docs: Build docs and commit them to staging repo

GIT_REF - Release tag or commit to build from
PACKAGE_VERSION - Release identifier in top level package directory (eg. 2.1.2-rc1)
BUILD_VERSION - (optional) Version being built (eg. 2.1.2)
ASF_USERNAME - Username of ASF committer
ASF_PASSWORD - Password of ASF committer account
GPG_KEY - GPG key used to sign release artifacts
GPG_PASSPHRASE - Passphrase for GPG key
EOF
  exit 1
}

if [ $# -eq 0 ]; then
  echo "usage: release-details.sh <package|docs>"
fi

error() {
  echo "$*"
  exit 1
}

if [ $# -eq 0 ]; then
  exit_with_usage
fi


if [[ $@ == *"help"* ]]; then
  echo "help is on its way."
fi


# Build docs (production)
if [[ "$1" == "docs" ]]; then
  cd systemds
  echo "Building SystemDS docs"

  cd docs

  bundle install
  PRODUCTION=1 RELEASE_VERSION="2.1.0" bundle exec jekyll build
fi


if [[ "$1" == "publish-snapshot" ]]; then
  cd systemds
  mvn deploy -DskipTests \
    -DaltSnapshotDeploymentRepository=sonatype-nexus-snapshots::default::http://localhost:8081/repository/sonatype-nexus-snapshot

fi

# if [[ -z "$GPG_KEY" ]]; then
#   echo "The environment variable $GPG_KEY is not set."
# fi

# GPG="gpg -u $GPG_KEY --no-tty --batch --pinentry-mode loopback"

# RELEASE_STAGING_LOCATION="https://dist.apache.org/repos/dist/dev/systemds"
# NEXUS_ROOT=https://repository.apache.org/service/local/staging

# make_binary_release
# 1. build with maven (java code)
# 2. sign artifacts
# 3. build python specific code
# 4. sign the artifacts
# 5. 

# echo $GPG_PASSPHRASE | $GPG --passphrase-fd 0 --armour \
#   --output $PYTHON_DIST_NAME.asc \
#   --detach-sig $PYTHON_DIST_NAME

# echo $GPG_PASSPHRASE | $GPG --passphrase-fd 0 --print-md \
  

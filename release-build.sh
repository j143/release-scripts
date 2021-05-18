#!/usr/bin/env bash

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

if [ $# -eq 0 ]; then
  echo "usage: release-details.sh <package|docs>"
fi

function error {
  echo "$*"
  exit 1
}

if [[ $@ == *"help"* ]]; then
  echo "help is on its way."
fi

cat <<EOF
================
Release details:
BRANCH:     $GIT_BRANCH
VERSION:    $RELEASE_VERSION
TAG:        $RELEASE_TAG
NEXT:       $NEXT_VERSION
ASF USER:   $ASF_USERNAME
GPG KEY:    $GPG_KEY
FULL NAME:  $GIT_NAME
E-MAIL:     $GIT_EMAIL
================
EOF

# cat pom.xml | grep -e '<version>.*</version>' |  head -n 2 | tail -n 1 | cut -d '>' -f2 | cut -d '<' -f1

# Find out the latest branch
# git ls-remote --head origin master | grep -v refs/head/master | awk '{print $2}' | head -n 1 | cut -d/ -f3
# master

function init_java {
    if [ -z "$JAVA_HOME"]; then
      error "JAVA_HOME is not set."
    fi
    JAVA_VERSION=$("${JAVA_HOME}"/bin/javac -version 2>&1 | cut -d " " -f2)
    export JAVA_VERSION
    echo "$JAVA_VERSION"
}

init_java

# check maven version
mvn -version 2>&1 | grep 'Maven home' | awk '{print $NF}'
# /usr/local/apache-maven-3.5.4

# Build maven package

git_hash=`git rev-parse --short HEAD`

export GIT_HASH=$git_hash

echo "Checked out SystemDS git has $git_hash"
Checked out SystemDS git has bef8ec754

cd ..

tar cvzf systemds-2.1.0.tgz --exclude systemds-2.1.0/.git systemds-2.1.0

shasum -a 512 systemds-2.1.0.tgz > systemds-2.1.0.tgz.sha512

rm -rf systemds-2.1.0

# making binary release

cp -r systemds systemds-2.1.0-bin
cd systemds-2.1.0-bin

echo "Creating distribution: systemds-2.1.0-bin"

# Build docs (production)

cd systemds
echo "Building SystemDS docs"

cd docs

bundle install
PRODUCTION=1 RELEASE_VERSION="2.1.0" bundle exec jekyll build

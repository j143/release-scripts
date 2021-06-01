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

GPG_OPTS="-Dgpg.keyname=$GPG_KEY -Dgpg.passphrase=$GPG_PASSPHRASE"

cat <<EOF >tmp-settings.xml
<settings><servers><server>
<id>apache.snapshots.https</id><username>$ASF_USERNAME</username>
<password>$ASF_PASSWORD</password>
</server></servers></settings>
EOF

if [[ "$1" == "publish-snapshot" ]]; then
  
  # -DaltSnapshotDeploymentRepository=sonatype-nexus-snapshots::default::http://localhost:8081/repository/sonatype-nexus-snapshot
  mvn --settings tmp-settings.xml deploy -DskipTests \
    -DaltSnapshotDeploymentRepository=github::default::https://maven.pkg.github.com/j143/systemds \
    ${GPG_OPTS}

fi

RELEASE_STAGING_LOCATION="https://dist.apache.org/repos/dist/dev/systemds"
DEST_DIR_NAME="$PACKAGE_VERSION"
if [[ "$1" == "publish-apache-staging" ]]; then

  svn co --depth=empty $RELEASE_STAGING_LOCATION svn-systemds
  rm -rf "svn-systemds/${DEST_DIR_NAME}"
  mkdir -p "svn-systemds/${DEST_DIR_NAME}"

  printf "Copy the release tarballs to svn repo"
  cp systemds-* "svn-systemds/${DEST_DIR_NAME}/"
  svn add "svn-systemds/${DEST_DIR_NAME}"

  cd svn-systemds
  svn ci --username "$ASF_USERNAME" --password "$ASF_PASSWORD" -m"Apache SystemDS $SYSTEMDS_PACKAGE_VERSION" --no-auth-cache
  cd ..
  rm -rf svn-systemds

fi


if [[ "$1" == "publish-staging" ]]; then

  mvn --settings tmp-settings.xml -P'distribution,rat' deploy \
    -DskiptTests \
    -DaltDeploymentRepository=github::default::https://maven.pkg.github.com/j143/systemds \
    ${GPG_OPTS}
fi

# if [[ -z "$GPG_KEY" ]]; then
#   echo "The environment variable $GPG_KEY is not set."
# fi

# GPG="gpg -u $GPG_KEY --no-tty --batch --pinentry-mode loopback"

# Publishing to Sonatype repo
NEXUS_ROOT=https://repository.apache.org/service/local/staging
NEXUS_PROFILE=1486a6e8f50cdf

printf "Creating a Nexus staging repository \n"
promote_request="<promoteRequest><data><description>Apache SystemDS</description></data></promoteRequest>"
out=$(curl -X POST -d "$promote_request" -u $ASF_USERNAME:$ASF_PASSWORD \
  -H "Content-Type:application/xml" -v \
  $NEXUS_ROOT/profiles/$NEXUS_PROFILE/start)
staged_repository_id=$(echo $out | sed -e "s/.*\(orgapachesystemds-[0-9]\{4\}\).*/\1/")

# upload files to nexus repo
nexus_upload_id=$NEXUS_ROOT/deployByRepositoryId/$staged_repository_id
printf "Upload files to $nexus_upload_id"

# for file in $(find . -type f)
# do
#   # strip leading ./
#   file_short=$(echo $file | sed -e "s/\.\///")
#   dest_url="$nexus_upload_id/org/apache/systemds/$file_short"
#   printf "Uploading $file_short"
#   curl -u $ASF_USERNAME:$ASF_PASSWORD --upload-file $file_short $dest_url
# done

# Promote the staging repository
# promote_request="<promoteRequest><data><stagedRepositoryId>$staged_repository_id</stagedRepositoryId></data></promoteRequest>"
# out=$(curl -X POST -d "$repo_request" -u $ASF_USERNAME:$ASF_PASSWORD \
#   -H "Content-Type:application/xml" -v \
#   $NEXUS_ROOT/profiles/$NEXUS_PROFILE/finish)
# printf "Closed Nexus staging repository: $staged_repository_id"

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
  

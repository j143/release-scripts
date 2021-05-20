#!/bin/sh
# Create release tags and version names


# mvn release:clean release:prepare
# provide values to the prompt
# version:
# tag:
# snapshot version:

mvn --batch-mode -Dtag=2.1.0-rc0 release:prepare \
                 -DreleaseVersion=2.1.0 \
                -DdevelopmentVersion=2.1.1-SNAPSHOT

# tag $VERSION-rc$RC_COUNT
# mvn --batch-mode -Dtag=$RELEASE_TAG release:prepare \
#                  -DreleaseVersion=$VERSION \
#                  -DdevelopmentVersion=$SNAPSHOT_VERSION

# mvn versions:set -DnewVersion=2.1.0
# [INFO] Local aggregation root: /home/sarita/systemds
# [INFO] Processing change of org.apache.systemds:systemds:2.1.0-SNAPSHOT -> 2.1.0
# [INFO] Processing org.apache.systemds:systemds
# [INFO]     Updating project org.apache.systemds:systemds
# [INFO]         from version 2.1.0-SNAPSHOT to 2.1.0

# mvn versions:set-scm-tag -DnewTag=v2.1.0-rc0
# [INFO] --- versions-maven-plugin:2.8.1:set-scm-tag (default-cli) @ systemds ---
# [INFO] Updating from tag HEAD > v2.1.0-rc0
# [INFO] ------------------------------------------------------------------------

# git commit -am "Preparing SystemDS release 2.1.0"
# [release-prepare bef8ec754] Preparing SystemDS release 2.1.0
#  5 files changed, 5 insertions(+), 5 deletions(-)

# echo "Creating tag v2.1.0-rc0 at present branch"

# do not use git tag
# git tag v2.1.0-rc0

# Create snapshot for the next release

# if ! is_dry_run; then
#   # Push changes
#   echo "git push origin $RELEASE_TAG"
#   #git push origin $RELEASE_TAG

#   # cd ..
#   # rm -rf systemds
# else
#   cd ..
#   mv systemds systemds.tag
#   echo "Clone with version changes and tag available as systemds.tag in the output directory."
# fi 

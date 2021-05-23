#!/bin/sh
# Create release tags and version names



mvn --batch-mode -DdryRun=true -Dtag=2.1.0-rc0 release:prepare \
                 -Dresume=false \
                 -DreleaseVersion=2.1.0 \
                 -DdevelopmentVersion=2.1.1-SNAPSHOT


# tag $VERSION-rc$RC_COUNT
# mvn --batch-mode -Dtag=$RELEASE_TAG release:prepare \
#                  -DreleaseVersion=$VERSION \
#                  -DdevelopmentVersion=$SNAPSHOT_VERSION


# the release candidate count
local RC_COUNT

VERSION="2.1.0-SNAPSHOT"
NEXT_VERSION="$VERSION"
RELEASE_VERSION="${VERSION/-SNAPSHOT/}"

REV=1 # rc1
# local PRE_REL_REV=$((REV - 1))
# local PRE_REL_TAG="v${SHORT_VERSION}.${PREV_REL_REV}"
RC_COUNT=1
# git ls-remote --tags "v${RELEASE_VERSION}-rc*" | wc -l

REV=0
NEXT_VERSION="2.1.${REV}-SNAPSHOT"


export NEXT_VERSION

# Release 



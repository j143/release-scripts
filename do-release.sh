#!/bin/sh


# Creates tag and push the commit.
./create-tag.sh

# Set Java version and build docs
# 
./release-build.sh
# $ ./do-release.sh
# [INFO] Scanning for projects...
# [INFO] 
# [INFO] --------------------< org.apache.systemds:systemds >--------------------
# [INFO] Building SystemDS 2.1.0-SNAPSHOT
# [INFO] --------------------------------[ jar ]---------------------------------
# [INFO] 
# [INFO] --- versions-maven-plugin:2.8.1:set (default-cli) @ systemds ---
# [INFO] Local aggregation root: /home/sarita/systemds
# [INFO] Processing change of org.apache.systemds:systemds:2.1.0-SNAPSHOT -> 2.1.0
# [INFO] Processing org.apache.systemds:systemds
# [INFO]     Updating project org.apache.systemds:systemds
# [INFO]         from version 2.1.0-SNAPSHOT to 2.1.0
# [INFO] 
# [INFO] ------------------------------------------------------------------------
# [INFO] BUILD SUCCESS
# [INFO] ------------------------------------------------------------------------
# [INFO] Total time: 26.883 s
# [INFO] Finished at: 2021-05-18T08:48:40+05:30
# [INFO] ------------------------------------------------------------------------
# [INFO] Scanning for projects...
# [INFO] 
# [INFO] --------------------< org.apache.systemds:systemds >--------------------
# [INFO] Building SystemDS 2.1.0
# [INFO] --------------------------------[ jar ]---------------------------------
# [INFO] 
# [INFO] --- versions-maven-plugin:2.8.1:set-scm-tag (default-cli) @ systemds ---
# [INFO] Updating from tag HEAD > v2.1.0-rc0
# [INFO] ------------------------------------------------------------------------
# [INFO] BUILD SUCCESS
# [INFO] ------------------------------------------------------------------------
# [INFO] Total time: 3.366 s
# [INFO] Finished at: 2021-05-18T08:48:47+05:30
# [INFO] ------------------------------------------------------------------------
# [release-check-1 09dc59b2f] Preparing SystemDS release 2.1.0
#  1 file changed, 2 insertions(+), 2 deletions(-)
# Creating tag v2.1.0-rc0 at present branch
# fatal: tag 'v2.1.0-rc0' already exists
# ./test.sh: 26: ./test.sh: is_dry_run: Permission denied
# git push origin 

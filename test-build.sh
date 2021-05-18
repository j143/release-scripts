#!/bin/sh

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

mvn -version 2>&1 | grep 'Maven home' | awk '{print $NF}'
# /usr/local/apache-maven-3.5.4

# TODO: python project version substitution with maven and build
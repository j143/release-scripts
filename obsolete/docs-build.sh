#!/bin/sh

cd systemds
echo "Building SystemDS docs"

cd docs

bundle install
PRODUCTION=1 RELEASE_VERSION="2.1.0" bundle exec jekyll build


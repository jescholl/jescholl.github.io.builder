#!/bin/sh
set -e

#copy compiled site to artifacts
rsync -a _site/ $CIRCLE_ARTIFACTS

#reset repo and checkout gh-pages
git fetch origin && \
git clean -fd && \
git checkout master && \
git reset --hard master && \
git checkout gh-pages && \
git reset --hard gh-pages
git clean -fd

#configure git commiter
git config --global user.name "CI"
git config --global user.email "ci@jescholl.com"

#copy compiled site from artifacts
rsync -a $CIRCLE_ARTIFACTS/ .

# commit changes
git add .
git commit -m "Updated by CI - All tests passed
$CIRCLE_BUILD_URL"
git push origin gh-pages

#ping search engines with new sitemap
curl "http://www.google.com/webmasters/sitemaps/ping?sitemap=http://jescholl.com/sitemap.xml"

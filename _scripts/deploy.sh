#!/bin/sh
set -e

if [ -z "$TARGET_REPO_URL" ]; then
  TARGET_REPO_URL=$CIRCLE_REPOSITORY_URL
fi

if [ -z "$TARGET_REPO_BRANCH" ]; then
  TARGET_REPO_BRANCH=master
fi

if [[ "$TARGET_REPO_BRANCH" == "$CIRCLE_BRANCH" && "$TARGET_REPO_URL" == "$CIRCLE_REPOSITORY_URL" ]]; then
  echo "Cannot deploy to current repo and branch"
  exit 1
fi

#copy compiled site to artifacts
rm -rf _site
bundle exec rake build:prod
rsync -a _site/ $CIRCLE_ARTIFACTS

#clone target repo to a temp dir to ensure no name collisions
TMPDIR=$(mktemp -d)
git clone $TARGET_REPO_URL $TMPDIR/target_repo
cd $TMPDIR/target_repo

#verify clean repo
git fetch origin
git checkout $TARGET_REPO_BRANCH

#configure git commiter
git config --global user.name "CI"
git config --global user.email "ci@jescholl.com"

#copy compiled site from artifacts
rsync -a $CIRCLE_ARTIFACTS/ .

# commit changes
git add .
git commit -m "Updated by CI - All tests passed
$CIRCLE_BUILD_URL"
git push origin master

#ping search engines with new sitemap
curl "http://www.google.com/webmasters/sitemaps/ping?sitemap=https://jescholl.com/sitemap.xml"

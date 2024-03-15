#!/bin/bash
die() { echo "$*" 1>&2 ; exit 1; }
cd $(dirname $0)
set -e -x

#
# copies the build directory output to the appropriate domain's repository,
# makes the required modifications and publishes them to GitHub Pages.
# arguments:
# 1. domain to which the static export should be deployed (e.g. example.com)
#    there must be a repository/directory with that domain name
#

if [ -f .env ]; then
  . .env
else
  die "missing .env file"
fi

[ "$#" -eq 1 ] || die "1 argument required, $# provided"
DOMAIN="$1"

BUILD_DIR=../build
DOMAIN_DIR="../$DOMAIN"
COPY_DIR="$DOMAIN_DIR/copy"
REL_OUT_DIR=docs
OUT_DIR="$DOMAIN_DIR/$REL_OUT_DIR"

# must have an appropriate directory in the project root
[ -d "$DOMAIN_DIR" ] || die "repository for domain $DOMAIN does not exist"

# assure we are publishing under the correct GitHub user
if [ ! $(git config user.name) == "$EXPECTED_GIT_USER" ]; then
  die "incorrect GitHub user: $(git config user.name)"
fi

# apply changes to the appropriate repository
rm -rf $OUT_DIR
mkdir -p $OUT_DIR
cp -r $BUILD_DIR/. $OUT_DIR/
cp -r $COPY_DIR/. $OUT_DIR/

# modifications
SITEMAP_DOMAIN_IN=pi.local:4700
SITEMAP_DOMAIN_OUT="$DOMAIN"
SITEMAP_FILENAME=sitemap.xml
sed -i "s/http:\/\/$SITEMAP_DOMAIN_IN\/$SITEMAP_FILENAME/https:\/\/$SITEMAP_DOMAIN_OUT\/$SITEMAP_FILENAME/g" $OUT_DIR/robots.txt

# preview
#python3 -m http.server -d $OUT_DIR 5001

# commit
cd "$DOMAIN_DIR"
git reset
git add "$REL_OUT_DIR"
git diff --cached --quiet --exit-code || git commit -m "deploy"

# squash all commits into one
git checkout --orphan new-main main
git commit -m "$(date +"automated deployment %Y-%m-%d %H:%M:%S")"
git branch -M new-main main

# deploy to GitHub Pages
git push -u origin main --force

set +x
echo
echo "Success! $DOMAIN has been published."

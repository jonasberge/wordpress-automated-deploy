#!/bin/bash
die() { echo "$*" 1>&2 ; exit 1; }
cd $(dirname $0)
set -e

#
# builds the static export of the configured Wordpress site.
# which site is built is configured in the .env file.
#

if [ -f .env ]; then
 . .env
else
  die "missing .env file"
fi

BUILD_DIR=../build
rm -rf $BUILD_DIR

# run static export with Staatic, make sure the deployment target is "Directory"
docker compose -f "$DOCKER_COMPOSE_PATH" run --rm wpcli staatic publish

# copy static export to build dir
docker cp "$DOCKER_WORDPRESS_CONTAINER:$STAATIC_DEPLOY_PATH" $BUILD_DIR

cd "$BUILD_DIR"

# fix syntax error caused by staatic (who knows why it exists?)
sed -i "s/sitemap.xsl'>/sitemap.xsl'?>/g" sitemap*

# remove unused uploads (staatic exports all uploads!!)
echo "Removing uploads that were exported but that are not used... (this could take a few seconds)"
KEPT_COUNT=0
DELETED_COUNT=0
for filename in $(find wp-content/uploads -type f); do
  if ! grep -q --include=\*.{html,xhtml} -rnw . -e "$filename"; then
    rm -f "$filename"
    let DELETED_COUNT+=1
  else
    let KEPT_COUNT+=1
  fi
done
echo "Deleted $DELETED_COUNT unused uploads ($KEPT_COUNT uploads are referenced and were kept)"

echo
echo "Success! Export finished."

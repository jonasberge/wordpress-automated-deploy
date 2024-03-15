#!/bin/bash
cd $(dirname $0)
set -e

if [ -f .env ]; then
  . .env
else
  die "missing .env file"
fi

for target in $DEPLOY_TARGETS; do
  echo
  echo "> Publishing $target"
  ./deploy.sh "$target"
done

echo
echo "Success! Both domains have been published."

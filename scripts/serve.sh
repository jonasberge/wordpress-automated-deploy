#!/bin/bash
die() { echo "$*" 1>&2 ; exit 1; }
cd $(dirname $0)
set -e

BUILD_DIR=../build

# must have an appropriate directory in the project root
[ -d "$BUILD_DIR" ] || die "you must trigger a build first"

PORT=5001

(sleep 0.5 && echo "Vorschau unter folgender Adresse öffnen: http://$(hostname).local:$PORT" &)

python3 -m http.server -d "$BUILD_DIR" "$PORT"

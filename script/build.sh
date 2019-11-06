#!/bin/bash


(
echo $HOUDINI_WATCH
set -e
set -o pipefail
export DATABASE_URL=${BUILD_DATABASE_URL:-postgres://admin:password@db/commitchange_development}
echo $DATABASE_URL
 yarn export-i18n && yarn generate-api-js

if [ -n "$HOUDINI_WATCH" ];
then
    echo "we're gonna watch!!!"
    bin/webpack --watch
else
    echo "we're gonna build!!!"
    NODE_ENV=production yarn webpack -p
fi
)
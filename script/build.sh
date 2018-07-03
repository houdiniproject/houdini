#!/bin/bash


(
echo $HOUDINI_WATCH
set -e
set -o pipefail
export DATABASE_URL=${BUILD_DATABASE_URL:-postgres://admin:password@db/commitchange_development}
echo $DATABASE_URL
npm run export-button-config && npm run export-i18n && npm run generate-api-js

if [ -n "$HOUDINI_WATCH" ];
then
    echo "we're gonna watch!!!"
    npx webpack --watch
else
    echo "we're gonna build!!!"
    NODE_ENV=production npx webpack -p
fi
)
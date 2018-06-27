#!/bin/bash


(
echo $HOUDINI_WATCH
set -e
set -o pipefail
export DATABASE_URL=${BUILD_DATABASE_URL:-postgres://admin:password@db/commitchange_development}
echo $DATABASE_URL
npm run export-button-config && npm run export-i18n && npm run generate-api-js

if [ -z "$HOUDINI_WATCH"} ];
then
    npx webpack --watch
else
    NODE_ENV=production npx webpack -p
fi
)
#!/bin/bash


(
echo $HOUDINI_WATCH
set -e
set -o pipefail
export DATABASE_URL=${BUILD_DATABASE_URL:-postgres://admin:password@localhost/commitchange_development_legacy}
echo $DATABASE_URL
yarn export-button-config && yarn export-i18n

if [ -n "$HOUDINI_WATCH" ];
then
    echo "we're gonna watch!!!"
    yarn webpack --watch
else
    echo "we're gonna build!!!"
    NODE_ENV=production yarn webpack -p
fi
)
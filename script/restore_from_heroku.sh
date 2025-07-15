#!/bin/bash
set -e


curl -o ${CC_PROD_DUMP_PATH:-"db/dumps/$(date +%Y%m%d%H%M%S).dump"} `heroku pg:backups:url -a commitchange`
bin/rails dumpcar:restore

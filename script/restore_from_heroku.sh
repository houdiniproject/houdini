#!/bin/bash
set -e


curl -o latest.dump `heroku pg:backups:url -a commitchange`
script/pg_restore_local_from_production.sh

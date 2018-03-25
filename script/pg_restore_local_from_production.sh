#!/bin/bash
set -e

curl -o latest.dump `heroku pg:backups public-url -a commitchange`
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U admin -d commitchange_development latest.dump

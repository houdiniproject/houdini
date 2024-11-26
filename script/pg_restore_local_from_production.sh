#!/bin/bash
set -e

pg_restore --verbose --clean --no-acl --no-owner -h ${DATABASE_HOST:-localhost} -U admin -d commitchange_development_legacy latest.dump

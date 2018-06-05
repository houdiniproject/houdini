#!/bin/bash
set -e

pg_restore --verbose --clean --no-acl --no-owner -h db -U admin -d commitchange_development latest.dump

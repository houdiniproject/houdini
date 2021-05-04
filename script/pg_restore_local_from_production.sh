#!/bin/bash
set -e

pg_restore --verbose --clean --no-acl --no-owner -h localhost -U houdini_user -d houdini_development latest.dump

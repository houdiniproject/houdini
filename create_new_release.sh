#!/usr/bin/env bash
current_commit=$( git rev-parse HEAD )

git checkout PRIVATE_MASTER

git merge --no-commit $current_commit

echo $current_commit > CCS_HASH
git add CCS_HASH
git commit -m "Release of source for $current_commit"

#!/usr/bin/env bash
current_commit=$( git rev-parse HEAD )
current_branch=$( git rev-parse --abbrev-ref HEAD )

git checkout PRIVATE_STAGING_MASTER

git merge --no-commit $current_branch

echo $current_commit > CCS_HASH
git add CCS_HASH
git commit -m "Release of source for $current_commit"

#!/usr/bin/env bash
set -e
curl -sL https://deb.nodesource.com/setup_18.x | bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

apt-get update -qq && apt-get install -y nodejs yarn

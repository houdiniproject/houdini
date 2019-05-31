#!/usr/bin/env bash
set -e
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt-get update -qq && apt-get install -y nodejs
npm install npm@^6 -g
npm install -g icu4c-data@64l
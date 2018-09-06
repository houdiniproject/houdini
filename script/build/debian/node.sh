#!/usr/bin/env bash
set -e

curl -sL https://deb.nodesource.com/setup_9.x | bash -
apt-get update -qq && apt-get install -y nodejs
npm install npm@^6 -g
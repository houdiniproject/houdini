#!/usr/bin/env bash
set -e

curl -sL https://deb.nodesource.com/setup_13.x | bash -

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-9.6 default-jre yarn
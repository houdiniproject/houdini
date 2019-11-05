#!/bin/bash
yarn ci && rake db:create db:structure:load db:migrate && RAILS_ENV=test rake db:create db:structure:load test:prepare && rake spec && yarn run build-all && yarn jest
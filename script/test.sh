#!/bin/bash
yarn ci && rake db:create db:schema:load db:migrate && RAILS_ENV=test rake db:create db:schema:load test:prepare && rake spec && yarn run build-all && yarn jest

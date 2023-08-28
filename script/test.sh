#!/bin/bash
yarn ci && bin/rails db:create db:schema:load db:migrate && RAILS_ENV=test bin/rails db:create db:schema:load test:prepare && bin/rails spec && yarn run build-all && yarn test:js

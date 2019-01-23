#!/bin/bash
npm ci --unsafe-perm && rake db:create db:structure:load db:migrate && RAILS_ENV=test rake db:create db:structure:load test:prepare && rake spec && npm run ci-build-all && npx jest
#!/bin/bash
rake db:create db:structure:load db:migrate && RAILS_ENV=test rake db:create db:structure:load test:prepare && rake spec && npm run ci-build-all && npm run jest
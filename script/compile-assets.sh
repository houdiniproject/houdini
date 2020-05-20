#!/bin/bash
( RAILS_ENV=${RAILS_ENV:-production} DATABASE_URL=${BUILD_DATABASE_URL:-postgres://admin:password@db/commitchange_development} bundle exec rake assets:precompile )

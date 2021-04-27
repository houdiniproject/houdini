#!/bin/bash
( RAILS_ENV=${RAILS_ENV:-production} DATABASE_URL=${BUILD_DATABASE_URL:-postgres://admin:password@localhost/commitchange_development_legacy} bundle exec rake assets:precompile )

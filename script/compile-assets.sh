#!/bin/bash
( RAILS_ENV=${RAILS_ENV:-production} DATABASE_URL=${BUILD_DATABASE_URL:-postgres://admin:password@db/houdini_development} bundle exec bin/rails assets:precompile )

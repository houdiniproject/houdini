#!/bin/bash
npm install && rake db:create db:structure:load test:prepare && rake spec && npx jest && npm run build-all
#!/bin/bash

dropdb commitchange_development ; dropdb commitchange_test ; rake db:drop ; rake db:setup ; rake db:migrate ; script/pg_restore_local_from_production.sh


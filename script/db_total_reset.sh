#!/bin/bash

dropdb houdini_development ; dropdb houdini_test ; bin/rails db:drop ; bin/rails db:setup ; bin/rails db:migrate ; script/pg_restore_local_from_production.sh


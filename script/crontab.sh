#!/bin/bash
echo "TEST"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )" ## root folder of the CC install
source "$HOME/.rvm/scripts/rvm" # $HOME is the user that runs the rail app... and rake
cd $DIR
bin/rails heroku_scheduled_job[pay_recurring_donations]

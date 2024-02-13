#!/bin/ash

cd /usr/src/app
rm -f ./tmp/pids/server.pid
rails db:migrate
bin/bundle exec puma -C config/puma.rb
# bin/rails s -u puma -p 3000 -b=0.0.0.0
#web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}

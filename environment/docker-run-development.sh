#!/usr/bin/env sh

cd /app
rm -f /app/tmp/pids/server.pid

#rails db:migrate RAILS_ENV=development
rails db:migrate
rails s -u puma -p 3000 -b=0.0.0.0

# TODO get debug version working
#bundle exec rdebug-ide --host 0.0.0.0 --dispatcher-port 33030 --port 13030 -- rails s -u puma -p 3000 -b=0.0.0.0



#cd /app && rm -f /app/tmp/pids/server.pid && rails s -u puma -p 3000 -b=0.0.0.0
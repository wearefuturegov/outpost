#!/usr/bin/env sh

cd /app
rm -f /app/tmp/pids/server.pid
rails db:migrate
rails s -u puma -p 3000 -b=0.0.0.0

#!/bin/sh
# https://stackoverflow.com/a/38732187/1935918
set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

bin/bundle exec rake db:migrate

exec bin/bundle exec "$@"

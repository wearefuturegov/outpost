#!/bin/sh
# https://stackoverflow.com/a/38732187/1935918
set -e

/bin/herokuish procfile exec bin/bundle exec rake db:migrate

# not sure this is needed on this image
# if [ -f /app/tmp/pids/server.pid ]; then
#   rm /app/tmp/pids/server.pid
# fi

# put things sort of back to default
# default entrypoint is /start
# pass cmd to /start
exec /start "$@"

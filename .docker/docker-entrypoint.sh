#!/bin/sh
# https://stackoverflow.com/a/38732187/1935918
set -e

# not sure this is needed on this image
# if [ -f /app/tmp/pids/server.pid ]; then
#   rm /app/tmp/pids/server.pid
# fi

# put things sort of back to default
# default entrypoint is /start
# pass cmd to /start (commands are defined in Proc file)
# set entrypoint to /exec to run custom commands
exec /start "$@"

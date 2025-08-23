#!/bin/bash

set -e

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

if [ "$1" = "bash" ]; then
  exec "$@"
else
  yarn install
  bundle check || bundle install

  exec "$@"
fi
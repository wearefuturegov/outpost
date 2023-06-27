#!/bin/bash

cd /app
rm -f /app/tmp/pids/server.pid
rails s -u puma -p 3000 -b=0.0.0.0

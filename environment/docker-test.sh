#!/bin/ash

cd /usr/src/app
rails db:drop
rails db:create
rails db:migrate

# Outpost

![Run tests](https://github.com/wearefuturegov/outpost/workflows/Run%20tests/badge.svg)

**[Staging site here](https://outpost-staging.herokuapp.com/)**

A standards-driven API and comprehensive set of admin tools for managing records about local community services, groups and activities.

It's a rails app backed by a postgres database.

## Running it locally

You need ruby installed and a postgresql server running.

First, clone the repo: 

```
bundle install
rails db:setup
rails s
```

For the database seed to succeed, you need a source data file `bucksfis.csv` in the `lib/seeds` folder.

## Running it on the web

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](
https://heroku.com/deploy)

Suitable for 12-factor app hosting like [Heroku](http://heroku.com).

It has a `Procfile` that will automatically run pending rails migrations on every deploy, to reduce downtime.

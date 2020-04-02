# Outpost

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


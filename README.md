<p align="center">
    <a href="https://outpost-staging.herokuapp.com/">
        <img src="https://github.com/wearefuturegov/outpost/blob/master/app/assets/images/outpost.png?raw=true" width="350px" />               
    </a>
</p>
  
<p align="center">
    <em>Service directories done right</em>         
</p>

---

![Run tests](https://github.com/wearefuturegov/outpost/workflows/Run%20tests/badge.svg)

**[Staging site here](https://outpost-staging.herokuapp.com/)**

A [standards-driven](https://opencommunity.org.uk/) API and comprehensive set of admin tools for managing records about local community services, groups and activities.

It's a rails app backed by a postgres database.

Outpost works alongside a [seperate API component](https://github.com/wearefuturegov/outpost-api-service/).

We're also building an [example front-end](https://github.com/wearefuturegov/scout-x) for Outpost.

## Running it locally

You need ruby and node.js installed, plus PostgreSQL server running.

If you want to build a public index for the API, you'll also need a local MongoDB server.

First, clone the repo. Then:

```
bundle install
npm install
rails db:setup
rails s

# run tests
rspec
```

For the database seed to succeed, you need a source data file `bucksfis.csv` in the `lib/seeds` folder.

### Building the public index

Outpost's API component relies on a public index stored on MongoDB.

You can run `rails build_public_index` to build the public index for the first time. Active record callbacks keep it up to date as services are changed, but it's a good idea to occasionally refresh the index by re-running that rake task

## Running it on the web

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](
https://heroku.com/deploy)

It's suitable for 12-factor app hosting like [Heroku](http://heroku.com).

It has a `Procfile` that will [automatically run](https://devcenter.heroku.com/articles/release-phase) pending rails migrations on every deploy, to reduce downtime.

## Config

It needs the following extra environment variables to be set:

- `GOOGLE_API_KEY` with the geocoding API enabled, to geocode postcodes
- `GOOGLE_CLIENT_KEY` with the javascript and static maps APIs enabled, to add map views to admin screens
- `OFSTED_API_KEY` to access the feed of Ofsted items

In production only:

- `SENDGRID_API_KEY` to send emails
- `MAILER_HOST` where the app lives on the web, to correctly form urls in emails
- `MAILER_FROM` the email address emails will be delivered from

## Running it locally

With [docker-compose](https://docs.docker.com/compose/) and [docker](https://www.docker.com/), after cloning the project:

- Bring up the databases with `docker-compose up`
- Populate your environment variables
- Run the application with `rails s`

## E2E Test Coverage
See the readme [here](https://github.com/wearefuturegov/outpost/tree/master/features)
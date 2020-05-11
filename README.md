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

We're also building an [example front-end](https://github.com/wearefuturegov/scout-x) for Outpost.

## Running it locally

You need ruby and node.js installed, plus a postgresql server running.

First, clone the repo: 

```
bundle install
npm install
rails db:setup
rails s

# run tests
rspec
```

For the database seed to succeed, you need a source data file `bucksfis.csv` in the `lib/seeds` folder.

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

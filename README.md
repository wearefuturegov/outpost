<p align="center">
    <a href="https://outpost-staging.herokuapp.com/">
        <img src="https://github.com/wearefuturegov/outpost/blob/develop/app/assets/images/outpost.png?raw=true" width="350px" />               
    </a>
</p>
  
<p align="center">
    <em>Service directories done right</em>
</p>

---

<p align="center">
   <img src="https://github.com/wearefuturegov/outpost/raw/develop/docs/intro-outpost.png?raw=true" width="750px" />     
</p>

<p align="center">
    <em>Example screens from the app</em>         
</p>

---

[![Run tests](https://github.com/wearefuturegov/outpost/workflows/Run%20tests/badge.svg)](https://github.com/wearefuturegov/outpost/actions)

- [Introduction](#introduction)
- [🌏 Deployment](#-deployment)
  - [🧱 Tech stack](#-tech-stack)
  - [🪄 Requirements](#-requirements)
  - [🌎 Running it on the web](#-running-it-on-the-web)
  - [💻 Running it locally](#-running-it-locally)
- [🪴 Usage](#-usage)
- [🧬 Configuration](#-configuration)
  - [Environmental Variables](#environmental-variables)
  - [Tasks](#tasks)
  - [Settings page](#settings-page)
- [✨ Features](#-features)
  - [Outpost API](#outpost-api)
  - [Data import](#data-import)
  - [OAuth provider](#oauth-provider)
  - [File uploads](#file-uploads)
  - [Ofsted integration](#ofsted-integration)
  - [Directories](#directories)
- [🧪 Tests](#-tests)
  - [Code coverage](#code-coverage)
  - [Compile assets](#compile-assets)

# Introduction

Outpost is a [standards-driven](https://opencommunity.org.uk/) service management application, API and comprehensive set of admin tools for managing records about local community services, groups and activities. It is part of the [Outpost Platform](https://outpost-platform.wearefuturegov.com/).

Outpost works alongside a [seperate API component](https://github.com/wearefuturegov/outpost-api-service/) and [Scout](https://github.com/wearefuturegov/scout-x) a directory application.

It can also act as an OAuth provider via [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper).

# 🌏 Deployment

## 🧱 Tech stack

- Ruby on rails
- PostgreSQL database
- MongoDB database for use with [Outpost API](https://github.com/wearefuturegov/outpost-api-service/)

## 🪄 Requirements

- Ruby 3.0.3
- Postgresql 13.7
- Mongo 6
- Node 16.13.1
- Yarn 1.22.17

## 🌎 Running it on the web

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

For more information see [getting started](https://github.com/wearefuturegov/outpost/wiki/Getting-started)

This repository contains configurations for **Docker** and **docker-compose** (configured for development). It's also suitable for 12-factor app hosting like [Heroku](http://heroku.com). It has a `Procfile` that will [automatically run](https://devcenter.heroku.com/articles/release-phase) pending rails migrations on every deploy, to reduce downtime.

When deploying Outpost you will need to setup schedule specific tasks, see [configuration](#🧬-configuration) for more information.

Heroku will automatically setup SECRETS for you but in docker you will need to do this manually.

Generate a key by running:

```sh
rake secret
```

Run the following to create the values

```sh
bin/rails credentials:edit --environment production
```

## 💻 Running it locally

For more information see [getting started](https://github.com/wearefuturegov/outpost/wiki/Getting-started)

A `docker-compose.development.yml` file is included to run Outpost locally. You can combine this with other images to create a custom development environment of your setup.

See [configuration](#-configuration) for setting up environmental variables.

**Build the images**

```sh
cp -rp sample.env .env
```

**Build the images**

```sh
docker compose build
```

**Run the containers**

```sh
docker compose up -d
```

**Populate with dummy data**

```sh
# default accessibilities, send_needs and suitabilities only
docker compose exec outpost bin/rails db:seed

# create a default admin user
docker compose exec outpost bin/rails SEED_ADMIN_USER=true db:seed

# create dummy data
docker compose exec outpost bin/rails SEED_DUMMY_DATA=true db:seed

# create default data
docker compose exec outpost bin/rails SEED_DEFAULT_DATA=true db:seed

```

The database will be seeded with realistic fake data as well as the default data and initial admin user required.
The application will be running on `localhost:3000`. You can log in with `example@example.com` and the initial password you set [in the configuration](#-configuration).

**Run the rails console**

```sh
docker compose exec outpost bin/rails c
```

**Run tests**

```sh
docker compose exec outpost bundle exec rspec
```

**Run end to end tests**

```sh
docker compose exec outpost rake
```

# 🪴 Usage

For more documentation on how to use Outpost see the [documentation](https://outpost-platform.wearefuturegov.com/docs/outpost)

# 🧬 Configuration

## Environmental Variables

You can provide config with a `.env` file. Run `cp sample.env .env` to create a fresh one.

The following environmental variables are required for minimal setup of Outpost.

**Environment specific**

| Variable                   | Description                                                                                                       | Example                    | Required?                                      |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------- | -------------------------- | ---------------------------------------------- |
| `SHOW_ENV_BANNER`          | show a bright warning banner on non-production environments                                                       | staging                    | Only to warn about non-production environments |
| `RAILS_ENV`                | Rails environment                                                                                                 | production                 | No, defaults to production                     |
| `NODE_ENV`                 | Node environment                                                                                                  | production                 | No, defaults to production                     |
| `PROJECT_NAME`             | Determines the name of the group in docker                                                                        | outpost_development        | No                                             |
| `LANG`                     | Determines the default language                                                                                   | en_US.UTF-8                | No                                             |
| `RAILS_SERVE_STATIC_FILES` | Tells rails to serve static assets                                                                                | true                       | Yes in production when using docker            |
| `SECRET_KEY_BASE`          | In docker environment required to compile assets successfully run: `RAILS_ENV=production rake secret` to generate | randomlettersandcharacters | Yes in production when using docker            |

**Databases**

| Variable       | Description                               | Example                                                 | Required?                                         |
| -------------- | ----------------------------------------- | ------------------------------------------------------- | ------------------------------------------------- |
| `DATABASE_URL` | the main PostgreSQL database              | postgres://user:password<br/>@example.com:5432/database | Yes, if different from default, and in production |
| `DB_URI`       | the MongoDB database for the public index | mongodb://user:password<br/>@example.com/database       | Yes, if using the API service                     |

**Emails**

| Variable             | Description                                                                                  | Example             | Required?          |
| -------------------- | -------------------------------------------------------------------------------------------- | ------------------- | ------------------ |
| `NOTIFY_API_KEY`     | to send emails with [Notify](https://www.notifications.service.gov.uk)                       |                     | In production only |
| `NOTIFY_TEMPLATE_ID` | ID of a notify template, as described [here](https://github.com/dxw/mail-notify#with-a-view) |                     | In production only |
| `MAILER_FROM`        | Who are the emails sent from Outpost from                                                    | example@example.com | In production only |
| `MAILER_HOST`        | where the app lives on the web, to correctly form urls in emails                             | https://example.com | In production only |

**Google Maps**

| Variable            | Description                                                                         | Example | Required?                   |
| ------------------- | ----------------------------------------------------------------------------------- | ------- | --------------------------- |
| `GOOGLE_API_KEY`    | with the geocoding API enabled, to geocode postcodes                                |         | Yes, for geocoding features |
| `GOOGLE_CLIENT_KEY` | with the javascript and static maps APIs enabled, to add map views to admin screens |         | Yes, for map features       |

**Initialisation and setup**

You can make use of the `INITIAL_ADMIN_PASSWORD` environmental variable when initialising your application.

| Variable                 | Description                                                    | Example            | Required?    |
| ------------------------ | -------------------------------------------------------------- | ------------------ | ------------ |
| `INITIAL_ADMIN_PASSWORD` | an initial admin password to log in with for local development |                    | Locally only |
| `MONGO_INITDB_DATABASE`  | Name of database to create and initialise in docker container  | outpost_production | No           |
| `POSTGRES_USER`          | User to create and initialise in docker container              | outpost_production | No           |
| `POSTGRES_PASSWORD`      | Database password to create and initialise in docker container | outpost_production | No           |
| `POSTGRES_DB`            | Name of database to create and initialise in docker container  | outpost_production | No           |

**Deprecated**

The following ENV variables are or will soon be deprecated.

| Variable            | Description                                                                                   | Example             | Required?          |
| ------------------- | --------------------------------------------------------------------------------------------- | ------------------- | ------------------ |
| `INSTANCE`          | Instance name, used with the directories feature and to customise some parts of the interface | buckinghamshire     | No                 |
| `FEEDBACK_FORM_URL` | a form where users can submit feedback about the website                                      | https://example.com | In production only |

## Tasks

Outpost depends on on several important [`rake`](https://guides.rubyonrails.org/v3.2/command_line.html) tasks.

Some of these can be run manually, and some are best scheduled using [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler) or similar.

| Task                          | Description                                                                                                                                                  | Suggested schedule |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------ |
| `open_objects:import`         | Run the bespoke import job from Open Objects. For this to succeed, you need several source CSV data files in the `/lib/seeds` folder. Will take a long time. | One\-off           |
| `build_public_index`          | Build the initial public index for the API service to use\.                                                                                                  | One\-off           |
| `process_permanent_deletions` | Permanently delete any services and users that have been "discarded" for more than 30 days\.                                                                 | Weekly             |
| `ofsted:create_initial_items` | Build the initial Ofsted items table                                                                                                                         | One\-off           |
| `ofsted:update_items`         | Check for any changes to Ofsted items against the Ofsted API                                                                                                 | Daily, overnight   |
| `update_counters:all`         | Update the counter caches to keep them in sync                                                                                                               | Daily, overnight   |

## Settings page

There is a settings page located at `/admin/settings/edit` where you can configure certain aspects of the Outpost interface.

A user will need to have the `superadmin` permission in order to access this page.

# ✨ Features

## Outpost API

Outpost's API component relies on a public index stored on MongoDB.

You can run `rails build_public_index` to build the public index for the first time. Active record callbacks keep it up to date as services are changed.

## Data import

See documentation on [data import](lib/tasks/data_import/README.md).

## OAuth provider

Outpost can work as an identity provider for other apps. Users with the highest permissions can access the `/oauth/applications` route to create credentials.

Once authenticated, consumer apps can fetch information about the currently logged in user with the `/api/v1/me` endpoint.

## File uploads

Currently these are only used in the settings page to replace the site logo so these details are not required.

| Variable                   | Description                         | Example | Required? |
| -------------------------- | ----------------------------------- | ------- | --------- |
| `GCP_PROJECT`              | Name of the google cloud project    | \*      | No        |
| `GCP_BUCKET`               | Name of the google cloud bucket     | \*      | No        |
| `GCP_PROJECT_ID`           | Name of the google cloud project id | \*      | No        |
| `GCP_PRIVATE_KEY_ID`       | Google cloud private key id         | \*      | No        |
| `GCP_PRIVATE_KEY`          | Google cloud private key            | \*      | No        |
| `GCP_CLIENT_EMAIL`         | Google cloud client email           | \*      | No        |
| `GCP_CLIENT_ID`            | Google cloud client id              | \*      | No        |
| `GCP_CLIENT_X509_CERT_URL` | Google cloud x509 certificate       | \*      | No        |

## Ofsted integration

Outpost can integrate with the Ofsted API to bring in a list of records and create service entries from them.

The following ENV vars are used to enable this functionality

| Variable                   | Description                        | Example | Required?                         |
| -------------------------- | ---------------------------------- | ------- | --------------------------------- |
| `OFSTED_API_KEY`           | to access the feed of Ofsted items |         | Only if running Ofsted rake tasks |
| `OFSTED_FEED_API_ENDPOINT` | to access the feed of Ofsted items |         | Only if running Ofsted rake tasks |

## Directories

NB this feature is subject to change at any time

There is a feature called directories in Outpost which lets you configure named directories or teams, this changes the interface so that services can be viewed all together or per directory, for example Family information services and Adult Social Care.

To see multiple directories in Outpost, run the app with:

```
INSTANCE=buckinghamshire rails s
```

This will start the app with the directories listed in `config/app_config.yaml`.

To add more directories, or set up another instance with separate directories,
edit `config/app_config.yaml`.

# 🧪 Tests

It has some rspec tests on key functionality. Run them with:

```sh
bundle exec rspec
```

## Code coverage

SimpleCov and Codecov are set up to track code coverage. To see the code
coverage on a local branch, run the test suite and open `coverage/index.html`:

```sh
rake
open coverage/index.html
```

The coverage report is sent to Codecov after the tests run in CI. Once you open
a PR, Codecov will post a comment with a handy coverage delta and a link to view
line-by-line coverage for the PR.

## Compile assets

Its also a good idea to check that assets are able to be precompiled before deploying

```sh
bundle exec rails assets:precompile
```

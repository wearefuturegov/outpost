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

A [standards-driven](https://opencommunity.org.uk/) API and comprehensive set of admin tools for managing records about local community services, groups and activities.

Outpost works alongside a [seperate API component](https://github.com/wearefuturegov/outpost-api-service/).

We're also building an [example front-end](https://github.com/wearefuturegov/scout-x) for Outpost.

## 🧱 How it's built

It's a Rails app backed by a PostgreSQL database.

It can also act as an OAuth provider via [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper).

It uses Google APIs for geocoding and map features, and Sendgrid to send emails.

## 💻 Running it locally

For more information see [getting started](https://github.com/wearefuturegov/outpost/wiki/Getting-started)

You need ruby and node.js installed, plus a PostgreSQL server running.

If you want to build a public index for the API, you'll also need a local MongoDB server.

First, clone the repo. Then:

```
docker compose -f docker-compose.development.yml build

docker compose -f docker-compose.development.yml up -d

# populate with dummy data
docker compose -f docker-compose.development.yml exec outpost-dev bin/rails db:seed

# or just create a single admin user
docker compose -f docker-compose.development.yml exec outpost-dev bin/rails c


# run tests
docker compose -f docker-compose.development.yml exec outpost-dev bundle exec rspec

# end to end tests
docker compose -f docker-compose.development.yml exec outpost-dev rake
```

The database will be seeded with realistic fake data.

It will be on `localhost:3000`. You can log in with `example@example.com` and the initial password you set [in the configuration](#-configuration).

### With multiple directories

To see multiple directories in Outpost, run the app with:

```
INSTANCE=buckinghamshire rails s
```

This will start the app with the directories listed in `config/app_config.yaml`.

To add more directories, or set up another instance with separate directories,
edit `config/app_config.yaml`.

### With Docker

With [docker-compose](https://docs.docker.com/compose/) and [docker](https://www.docker.com/), after cloning the project:

- Bring up the databases with `docker-compose up`
- Populate your environment variables
- Run the application with `rails s`

### Building a public index

Outpost's API component relies on a public index stored on MongoDB.

You can run `rails build_public_index` to build the public index for the first time. Active record callbacks keep it up to date as services are changed.

## 🌎 Running it on the web

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

It's suitable for 12-factor app hosting like [Heroku](http://heroku.com).

It has a `Procfile` that will [automatically run](https://devcenter.heroku.com/articles/release-phase) pending rails migrations on every deploy, to reduce downtime.

## 🗓 Administrative tasks

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

## 🧬 Configuration

You can provide config with a `.env` file. Run `cp .env.example .env` to create a fresh one.

It needs the following extra environment variables to be set:

| Variable                                        | Description                                                                                  | Example                                                 | Required?                                         |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------- |
| `GOOGLE_API_KEY`                                | with the geocoding API enabled, to geocode postcodes                                         |                                                         | Yes, for geocoding features                       |
| `GOOGLE_CLIENT_KEY`                             | with the javascript and static maps APIs enabled, to add map views to admin screens          |                                                         | Yes, for map features                             |
| `OFSTED_API_KEY` and `OFSTED_FEED_API_ENDPOINT` | to access the feed of Ofsted items                                                           |                                                         | Only if running Ofsted rake tasks                 |
| `NOTIFY_API_KEY`                                | to send emails with [Notify](https://www.notifications.service.gov.uk)                       |                                                         | In production only                                |
| `NOTIFY_TEMPLATE_ID`                            | ID of a notify template, as described [here](https://github.com/dxw/mail-notify#with-a-view) |                                                         | In production only                                |
| `MAILER_HOST`                                   | where the app lives on the web, to correctly form urls in emails                             | https://example.com                                     | In production only                                |
| `FEEDBACK_FORM_URL`                             | a form where users can submit feedback about the website                                     | https://example.com                                     | In production only                                |
| `DATABASE_URL`                                  | the main PostgreSQL database                                                                 | postgres://user:password<br/>@example.com:5432/database | Yes, if different from default, and in production |
| `DB_URI`                                        | the MongoDB database for the public index                                                    | mongodb://user:password<br/>@example.com/database       | Yes, if using the API service                     |
| `INITIAL_ADMIN_PASSWORD`                        | an initial admin password to log in with for local development                               |                                                         | Locally only                                      |
| `SHOW_ENV_BANNER`                               | show a bright warning banner on non-production environments                                  | staging                                                 | Only to warn about non-production environments    |
| `GCP_PROJECT`                                   | Name of the google cloud project                                                             | \*                                                      | No                                                |
| `GCP_BUCKET`                                    | Name of the google cloud bucket                                                              | \*                                                      | No                                                |
| `GCP_PROJECT_ID`                                | Name of the google cloud project id                                                          | \*                                                      | No                                                |
| `GCP_PRIVATE_KEY_ID`                            | Google cloud private key id                                                                  | \*                                                      | No                                                |
| `GCP_PRIVATE_KEY`                               | Google cloud private key                                                                     | \*                                                      | No                                                |
| `GCP_CLIENT_EMAIL`                              | Google cloud client email                                                                    | \*                                                      | No                                                |
| `GCP_CLIENT_ID`                                 | Google cloud client id                                                                       | \*                                                      | No                                                |
| `GCP_CLIENT_X509_CERT_URL`                      | Google cloud x509 certificate                                                                | \*                                                      | No                                                |

## 💿 Data import

See documentation on [data import](lib/tasks/data_import/README.md).

## 🔐 OAuth provider

Outpost can work as an identity provider for other apps. Users with the highest permissions can access the `/oauth/applications` route to create credentials.

Once authenticated, consumer apps can fetch information about the currently logged in user with the `/api/v1/me` endpoint.

## 🧪 Tests

It has some rspec tests on key functionality. Run them with:

```
bundle exec rspec
```

## Code coverage

SimpleCov and Codecov are set up to track code coverage. To see the code
coverage on a local branch, run the test suite and open `coverage/index.html`:

```
rake
open coverage/index.html
```

The coverage report is sent to Codecov after the tests run in CI. Once you open
a PR, Codecov will post a comment with a handy coverage delta and a link to view
line-by-line coverage for the PR.

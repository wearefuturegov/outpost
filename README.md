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

Outpost is part of [The Outpost Platform](https://outpost-platform.wearefuturegov.com/) a suite of applications, tools and resources that make new kinds of service directories possible. Its free, open source and community driven.

Outpost is designed to be combined with the [Outpost API](https://github.com/wearefuturegov/outpost-api-service/) which provides public data to other tools in the Outpost Platform ecosystem. There is also an example front-end for Outpost, [Scout](https://github.com/wearefuturegov/scout-x).

## 🧱 How it's built

Outpost is a a Rails app backed by a PostgreSQL database.

It can also act as an OAuth provider via [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper).

It uses Google APIs for geocoding and map features, and Gov Notify to send emails.

### Building a public index

Outpost's API component relies on a public index stored on MongoDB.

You can run `rails build_public_index` to build the public index for the first time. Active record callbacks keep it up to date as services are changed.

### Enable multiple directories feature

To see multiple directories in Outpost, run the app with:

```
INSTANCE=buckinghamshire rails s
```

This will start the app with the directories listed in `config/app_config.yaml`.

To add more directories, or set up another instance with separate directories,
edit `config/app_config.yaml`.

## 💻 Running it locally

For more information see [getting setup](https://outpost-platform.wearefuturegov.com/docs/outpost/developers/getting-setup)

With [docker-compose](https://docs.docker.com/compose/) and [docker](https://www.docker.com/), after cloning the project:

- Bring up the databases with `docker-compose up`
- Populate your environment variables
- Run the application with `rails s`

## 🌎 Running it on the web

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

It's suitable for 12-factor app hosting like [Heroku](http://heroku.com). It has a `Procfile` that will [automatically run](https://devcenter.heroku.com/articles/release-phase) pending rails migrations on every deploy, to reduce downtime.

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

## 🔐 OAuth provider

Outpost can work as an identity provider for other apps. Users with the highest permissions can access the `/oauth/applications` route to create credentials.

Once authenticated, consumer apps can fetch information about the currently logged in user with the `/api/v1/me` endpoint.

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
| `GCP_PROJECT`                                   | Name of the google cloud project                                                             | \*                                                      | Yes                                               |
| `GCP_BUCKET`                                    | Name of the google cloud bucket                                                              | \*                                                      | Yes                                               |
| `GCP_APPLICATION_CREDENTIALS`                   | JSON                                                                                         | \*                                                      | Yes                                               |

## 🌥 Google Cloud Active Storage

Setting up google cloud active storage.

When working locally, you can drop your `keyfile.json` into `config/secrets/gcp.json`

To deploy your credentials use

```sh
heroku config:set GCP_APPLICATION_CREDENTIALS="$(< config/secrets/gcp.json)" -a heroku-app-name
```

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
| `update_counters:all`         | Update the counter caches to keep them in sync                                                                                                               |

## 💿 Data import

## See documentation on [data import](lib/tasks/data_import/README.md).

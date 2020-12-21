<p align="center">
    <a href="https://outpost-staging.herokuapp.com/">
        <img src="https://github.com/wearefuturegov/outpost/blob/master/app/assets/images/outpost.png?raw=true" width="350px" />               
    </a>
</p>
  
<p align="center">
    <em>Service directories done right</em>         
</p>

---

<p align="center">
   <img src="https://github.com/wearefuturegov/outpost/raw/master/public/examples.jpg?raw=true" width="750px" />     
</p>

<p align="center">
    <em>Example screens from the app</em>         
</p>

---

[![Run tests](https://github.com/wearefuturegov/outpost/workflows/Run%20tests/badge.svg)](https://github.com/wearefuturegov/outpost/actions)

**[Staging site here](https://outpost-staging.herokuapp.com/)**

A [standards-driven](https://opencommunity.org.uk/) API and comprehensive set of admin tools for managing records about local community services, groups and activities.

Outpost works alongside a [seperate API component](https://github.com/wearefuturegov/outpost-api-service/).

We're also building an [example front-end](https://github.com/wearefuturegov/scout-x) for Outpost.

## 🧱 How it's built

It's a Rails app backed by a PostgreSQL database.

It can also act as an OAuth provider via [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper).

It uses Google APIs for geocoding and map features, and Sendgrid to send emails.

## 💻 Running it locally

You need ruby and node.js installed, plus a PostgreSQL server running.

If you want to build a public index for the API, you'll also need a local MongoDB server.

First, clone the repo. Then:

```
bundle install
npm install
rails db:setup
rails s

# run end-to-end and unit tests
rake
```

The database will be seeded with realistic fake data.

It will be on `localhost:3000`. You can log in with `example@example.com` and the initial password you set [in the configuration](#configuration).

### With Docker

With [docker-compose](https://docs.docker.com/compose/) and [docker](https://www.docker.com/), after cloning the project:

- Bring up the databases with `docker-compose up`
- Populate your environment variables
- Run the application with `rails s`

### Building a public index

Outpost's API component relies on a public index stored on MongoDB.

You can run `rails build_public_index` to build the public index for the first time. Active record callbacks keep it up to date as services are changed.

## 🌎 Running it on the web

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](
https://heroku.com/deploy)

It's suitable for 12-factor app hosting like [Heroku](http://heroku.com).

It has a `Procfile` that will [automatically run](https://devcenter.heroku.com/articles/release-phase) pending rails migrations on every deploy, to reduce downtime.


## 🗓 Administrative tasks

Outpost depends on on several important [`rake`](https://guides.rubyonrails.org/v3.2/command_line.html) tasks.

Some of these can be run manually, and some are best scheduled using [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler) or similar.

| Task                              | Description                                                                                                                                                        | Suggested schedule |
|-----------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------|
| `open_objects_import`             | Run the bespoke import job from Open Objects. For this to succeed, you need several source CSV data files in the `/lib/seeds` folder. Will take a long time.       | One\-off           |
| `build_public_index`              | Build the initial public index for the API service to use\.                                                                                                        | One\-off           |
| `process_permanent_deletions`     | Permanently delete any services that have been "discarded" for more than 30 days\.                                                                                 | Weekly             |
| `ofsted_create_initial_items`     | Build the initial Ofsted items table                                                                                                                               | One\-off           |
| `ofsted_update_items`             | Check for any changes to Ofsted items against the Ofsted API                                                                                                       | Daily, overnight   |


## 🧬 Configuration

You can provide config with a `.env` file. Run `cp .env.example .env` to create a fresh one.

It needs the following extra environment variables to be set:

| Variable                                         | Description                                                                         | Example                                                 | Required?                                         |
|--------------------------------------------------|-------------------------------------------------------------------------------------|---------------------------------------------------------|---------------------------------------------------|
| `GOOGLE_API_KEY`                                 | with the geocoding API enabled, to geocode postcodes                                |                                                         | Yes, for geocoding features                       |
| `GOOGLE_CLIENT_KEY`                              | with the javascript and static maps APIs enabled, to add map views to admin screens |                                                         | Yes, for map features                             |
| `OFSTED_API_KEY` and `OFSTED_FEED_API_ENDPOINT`  | to access the feed of Ofsted items                                                  |                                                         | Only if running Ofsted rake tasks                 |
| `SENDGRID_API_KEY`                               | to send emails                                                                      |                                                         | In production only                                |
| `MAILER_HOST`                                    | where the app lives on the web, to correctly form urls in emails                    | https://example.com                                     | In production only                                |
| `MAILER_FROM`                                    | the email address emails will be delivered from                                     | example@email.com                                       | In production only                                |
| `FEEDBACK_FORM_URL`                              | a form where users can submit feedback about the website                            | https://example.com                                     | In production only                                |
| `DATABASE_URL`                                   | the main PostgreSQL database                                                        | postgres://user:password<br/>@example.com:5432/database | Yes, if different from default, and in production |
| `DB_URI`                                         | the MongoDB database for the public index                                           | mongodb://user:password<br/>@example.com/database       | Yes, if using the API service                     |
| `INITIAL_ADMIN_PASSWORD`                         | an initial admin password to log in with for local development                      |                                                         | Locally only                                      |


## 🔐 OAuth provider

Outpost can work as an identity provider for other apps. Users with the highest permissions can access the `/oauth/applications` route to create credentials.

Once authenticated, consumer apps can fetch information about the currently logged in user with the `/api/v1/me` endpoint.

## 🧪 Tests

It has some rspec and cucumber tests on key functionality. Run them with: 

```
rake
```

See the [full docs](https://github.com/wearefuturegov/outpost/tree/master/features).
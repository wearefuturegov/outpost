<p align="center">
    <a href="https://outpost-platform.wearefuturegov.com/">
        <img src="app/assets/images/outpost.png?raw=true" width="350px" />               
    </a>
</p>
  
<p align="center">
    <em>Service directories done right</em>         
</p>

---

<p align="center">
   <img src="docs/examples.jpg?raw=true" width="750px" />     
</p>

<p align="center">
    <em>Example screens from the app</em>         
</p>

---

[![Run tests](https://github.com/wearefuturegov/outpost/workflows/Run%20tests/badge.svg)](https://github.com/wearefuturegov/outpost/actions)

**[More information here](https://outpost-platform.wearefuturegov.com/)**

A [standards-driven](https://opencommunity.org.uk/) API and comprehensive set of admin tools for managing records about local community services, groups and activities.

Outpost works alongside a [separate API component](https://github.com/wearefuturegov/outpost-api-service/).

We're also building an example front-end called [Scout](https://github.com/wearefuturegov/scout-x) for Outpost to get you up and running quickly.

## 🧱 How it's built

It's a Rails app backed by a PostgreSQL database.

It can also act as an OAuth provider via [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper).

It uses Google APIs for geocoding and map features, and gov notify to send emails.

## 🧬 Configure Outpost

**Custom templates**

See [app_config.yml](config/app_config.yml)

## 🌎 Running it on the web

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

It's suitable for 12-factor app hosting like [Heroku](http://heroku.com).

It has a `Procfile` that will [automatically run](https://devcenter.heroku.com/articles/release-phase) pending rails migrations on every deploy, to reduce downtime.

## 💻 Running it locally

For more in depth information see [getting setup](https://outpost-platform.wearefuturegov.com/docs/outpost/developers/getting-setup)

Using the docker development environment, no rails, postgres, mongo installation necessary!

```sh
cd ./environment

# skip if already done
cp .env.sample .env

# build everything
make build

# start the containers
make start

# initialise the DB
make shell
rails db:setup

# open outpost
make run

# or
make shell
rails s -u puma -p 3000 -b=0.0.0.0

# view site (url is set in environment/.env)
open http://outpost-dev.localhost

# run commands (rails, bundler etc)
make shell

# run rails commands
make rails_console

# stop the containers
make stop
```

### Creating users

```sh
make rails_console
```

```ruby
User.create!({ \
    first_name: "Test", \
    last_name: "Admin", \
    admin: true, \
    admin_users: true, \
    email: "admin@example.com", \
    password: "1234ABCabc" \
});
```

- `admin` = can see admin panel
- `admin_users` = can manage users
- `admin_users` = can manage ofsted feed
- `admin_manage_ofsted_access` = can allow others to manage who can give others access to manage the ofsted feed (yeh, we know)

### Migrations

If this is your first time running Outpost or its been a while you will need to run the database migrations.

You'll be prompted to do this when you open Outpost or you can run them manually.

```sh
rails db:migrate RAILS_ENV=development
```

### Seeding data

You can seed data by running the following. You can configure the default email and password in env variables.

```sh
make shell
rails db:seed
```

To add dummy data, you will need to open the [seeds.rb](db/seeds.rb) file and set `import_sample_data` to true.

### Working with gems, yarn and the docker development environment

If you make any changes to the gems, versions etc,

You will need to install gems through the `make shell` command so the correct versions of package managers are used.

You may also want to run the `make copy_gem_files` command. On your local environment this shouldn't be a problem but its just a good idea just in case!

If your testing or developing features around the docker implementation you will need to rebuild the `build_rails` layer in the [ruby Dockerfile](environment/containers/ruby/Dockerfile)

```sh
# install new gems
make shell
bundler add <gem>

# install new npm packages
make shell
yarn add <package>

# (optional) update your build files

# optional - update environment/artifacts/ruby gemfiles for the build commands
make copy_gem_files
make copy_node_files

# reference - rebuild if its needed for your task
make stop
docker-compose -f docker-compose.$(BUILD_TARGET).yml build ruby --no-cache
makr start
```

### Updating env files

When you make a change to the .env files you will need to quit and re-start the `rails s` command, either by cancelling `make run` or cancelling out of the `rails s` command in `make shell`

### Connecting to the database on your machine

nb: If you're running postgresql on your localmachine you'll need to stop the service

You should be able to connect via localhost.

### Building a public index

@TODO

Outpost's API component relies on a public index stored on MongoDB.

```sh
make shell
rails build_public_index
```

You can run `rails build_public_index` to build the public index for the first time. Active record callbacks keep it up to date as services are changed.

### Running the tests locally

@TODO chrome driver https://nicolasiensen.github.io/2022-03-11-running-rails-system-tests-with-docker/

See [tests](#🧪-tests) and [code coverage](#code-coverage).

```sh

# rspec
make shell
bundle exec rspec

# code coverage
make shell
rake
open coverage/index.html

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
| `update_counters:all`         | Update the counter caches to keep them in sync                                                                                                               | Daily, overnight   |

## 🔐 OAuth provider

Outpost can work as an identity provider for other apps. Users with the highest permissions can access the `/oauth/applications` route to create credentials.

Once authenticated, consumer apps can fetch information about the currently logged in user with the `/api/v1/me` endpoint.

## 🧪 Tests

It has some rspec tests on key functionality. Run them with:

```
make shell
bundle exec rspec

```

### Code coverage

SimpleCov and Codecov are set up to track code coverage. To see the code
coverage on a local branch, run the test suite and open `coverage/index.html`:

```

rake
open coverage/index.html

```

The coverage report is sent to Codecov after the tests run in CI. Once you open
a PR, Codecov will post a comment with a handy coverage delta and a link to view
line-by-line coverage for the PR.

```

```

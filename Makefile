.PHONY: help list

export DOCKER_BUILDKIT = 1



# $ herokuish

# Available commands:
#   buildpack                Use and install buildpacks
#     build                    Build an application using installed buildpacks
#     install                  Install buildpack from Git URL and optional committish
#     list                     List installed buildpacks
#     test                     Build and run tests for an application using installed buildpacks
#   help                     Shows help information for a command
#   paths                    Shows path settings
#   procfile                 Use Procfiles and run app commands
#     exec                     Run as unprivileged user with Heroku-like env
#     parse                    Get command string for a process type from Procfile
#     start                    Run process type command from Procfile through exec
#   slug                     Manage application slugs
#     export                   Export generated slug tarball to URL (PUT) or STDOUT
#     generate                 Generate a gzipped slug tarball from the current app
#     import                   Import a gzipped slug tarball from URL or STDIN
#   test                     Test running an app through Herokuish
#   version                  Show version and supported version info


help: ## Lists all documented Make targets.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m\make %-30s\033[0m %s\n", $$1, $$2}'
list: help

# we could also use make start cmd="up" but the docker image is set to use start as the entrypoint and up as the cmd by default
up: ## Start the application as if it were in production
	docker run --rm --name outpost_production \
	--platform linux/amd64 \
	--network outpost-production-network \
	-e PORT=3000 \
	-p 3002:3000/tcp \
	-e NODE_ENV=production \
	-e RAILS_ENV=production \
	-e "DATABASE_URL=postgresql://outpost:password@outpost-production-postgres:5432/outpost?" \
	-e "DB_URI=mongodb://outpost-production-mongo:27017/outpost_api_production" \
	outpost:production

pull: ## fetch the herokuish image
	docker pull gliderlabs/herokuish:latest-20

build: pull ## build the production image
	docker build \
	--platform linux/amd64 \
	--build-arg NODE_OPTIONS=--openssl-legacy-provider \
	--build-arg NODE_ENV=production \
	--build-arg RAILS_ENV=production \
	-f "Dockerfile.production" \
	-t outpost:production "."

exec: ## execute a command on the production image eg make exec cmd="bin/rails c"
	@if [ -z "$(cmd)" ]; then echo "cmd is required"; exit 1; fi
	docker run -it --rm \
	--name outpost_production_release \
	--platform linux/amd64 \
	--entrypoint /exec \
	--network outpost-production-network \
	-e NODE_ENV=production \
	-e RAILS_ENV=production \
	-e "DATABASE_URL=postgresql://outpost:password@outpost-production-postgres:5432/outpost?" \
	-e "DB_URI=mongodb://outpost-production-mongo:27017/outpost_api_production" \
	outpost:production $(cmd)

start: ## execute a command from the Procfile eg make start cmd=release 
	@if [ -z "$(cmd)" ]; then echo "cmd is required"; exit 1; fi
	docker run -it --rm \
	--name outpost_production_release \
	--platform linux/amd64 \
	--entrypoint /start \
	--network outpost-production-network \
	-e NODE_ENV=production \
	-e RAILS_ENV=production \
	-e "DATABASE_URL=postgresql://outpost:password@outpost-production-postgres:5432/outpost?" \
	-e "DB_URI=mongodb://outpost-production-mongo:27017/outpost_api_production" \
	outpost:production $(cmd)

# production

production: ## create a production environment
	docker network create outpost-production-network
	docker volume create outpost-production-mongo-volume
	docker volume create outpost-production-postgres-volume

	docker run -d --name outpost-production-mongo \
	--platform linux/amd64 \
	--network outpost-production-network \
	-p 27020:27017 \
	-v outpost-production-mongo-volume:/data/db \
	-v "./.docker/services/mongo/setup-mongodb.js:/docker-entrypoint-initdb.d/mongo-init.js:ro" \
	-e MONGO_INITDB_DATABASE=outpost_api_production \
	-e MONGO_INITDB_ROOT_PASSWORD=password \
	-e MONGO_INITDB_ROOT_USERNAME=outpost \
	mongo:6

	docker run -d --name outpost-production-postgres \
	--platform linux/amd64 \
	--network outpost-production-network \
	-p 5435:5432 \
	-v outpost-production-postgres-volume:/var/lib/postgresql/data \
	-e POSTGRES_DB=outpost_production \
	-e POSTGRES_PASSWORD=password \
	-e POSTGRES_USER=outpost \
	postgres:13.7-alpine

	make build
	make start cmd="release"
	make up

	ngrok http 3002

production-tidy: ## tidy up the production environment
	docker container stop outpost-production-postgres
	docker container stop outpost-production-mongo
	docker container stop outpost_production
	docker container rm outpost-production-postgres
	docker container rm outpost-production-mongo
	docker container rm outpost_production
	docker volume rm outpost-production-mongo-volume
	docker volume rm outpost-production-postgres-volume
	docker network rm outpost-production-network

production-delete:	
	docker image rm outpost:production

# test

tests: ## run tests as if it were in production but on local code
	docker network create outpost-test-network
	docker volume create outpost-test-mongo-volume
	docker volume create outpost-test-postgres-volume

	docker run -d --name outpost-test-mongo \
	--platform linux/amd64 \
	--network outpost-test-network \
	-p 27019:27017 \
	-v outpost-test-mongo-volume:/data/db \
	-v "./.docker/services/mongo/setup-mongodb.js:/docker-entrypoint-initdb.d/mongo-init.js:ro" \
	-e MONGO_INITDB_DATABASE=outpost_api_test \
	-e MONGO_INITDB_ROOT_PASSWORD=password \
	-e MONGO_INITDB_ROOT_USERNAME=outpost \
	mongo:6

	docker run -d --name outpost-test-postgres \
	--platform linux/amd64 \
	--network outpost-test-network \
	-p 5434:5432 \
	-v outpost-test-postgres-volume:/var/lib/postgresql/data \
	-e POSTGRES_DB=outpost_test \
	-e POSTGRES_PASSWORD=password \
	-e POSTGRES_USER=outpost \
	postgres:13.7-alpine

	make tests-local

tests-local: ## Run the tests from your local code
	docker run --rm --name outpost_test \
	--platform linux/amd64 \
	--network outpost-test-network \
	-e "DATABASE_URL=postgresql://outpost:password@outpost-test-postgres:5432/outpost?" \
	-e "DB_URI=mongodb://outpost-test-mongo:27017/outpost_api_test" \
	-e OFSTED_FEED_API_ENDPOINT=https://test-ofsted-feed.stub \
	-e NODE_ENV=development \
	-e RAILS_ENV=test \
	-v .:/tmp/app \
	gliderlabs/herokuish:latest-20 /bin/herokuish buildpack test

tests-tidy: ## tidy up test environment
	docker container stop outpost-test-postgres
	docker container stop outpost-test-mongo
	docker container stop outpost_test
	docker container rm outpost-test-postgres
	docker container rm outpost-test-mongo
	docker container rm outpost_test
	docker volume rm outpost-test-mongo-volume
	docker volume rm outpost-test-postgres-volume
	docker network rm outpost-test-network


# docker run --rm -v /abs/app/path:/tmp/app gliderlabs/herokuish /bin/herokuish buildpack test

# development
# some helpers when developing locally 

dev-up: ## run local development environment
	docker compose up -d

dev-build: ## build local image
	docker compose build

dev-build-dev-base: ## build the def base image locally
	docker build --progress=plain -f .docker/images/dev-base/Dockerfile -t outpost-dev-base .

dev-down: ## remove all local containers
	docker compose down

dev-seed: ## seed the local database with send_needs etc
	docker compose exec outpost bin/rails db:seed

dev-seed-admin: ## seed local database with send_needs etc and an admin user
	docker compose exec outpost bin/rails SEED_ADMIN_USER=true db:seed

dev-seed-data: ## seed local database with send_needs etc and dummy data
	docker compose exec outpost bin/rails SEED_DUMMY_DATA=true db:seed

dev-seed-all: ## seed local database with admin user, dummy data and send_needs etc
	docker compose exec outpost bin/rails SEED_ADMIN_USER=true  SEED_DUMMY_DATA=true db:seed

dev-ssh: ## access outpost from cli
	docker compose exec outpost bash

dev-railsc: ## run rails console
	docker compose exec outpost bin/rails c

dev-tests: ## run tests 
	# docker compose exec outpost bash -c "DISABLE_SPRING=1 NODE_ENV=development RAILS_ENV=test bundle exec rspec ./spec/features/filtering_services_spec.rb:64"
	# docker compose exec outpost bash -c "DISABLE_SPRING=1 NODE_ENV=development RAILS_ENV=test bundle exec rspec ./spec/features/test_for_tests.rb"
	docker compose exec outpost bash -c "DISABLE_SPRING=1 NODE_ENV=development RAILS_ENV=test bundle exec rspec"

dev-rake: ## run rake tasks
	docker compose exec outpost bash -c "DISABLE_SPRING=1 NODE_ENV=development RAILS_ENV=test rake"

dev-coverage: ## open test coverage summary
	open coverage/index.html
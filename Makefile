.PHONY: help list

export DOCKER_BUILDKIT = 1

# herokuish cheatsheet for when you can't run herokuish --help
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


test_network_name=outpost-test-network

test_mongo_container_name=outpost-test-mongo
test_mongo_port=27019
test_mongo_volume_name=outpost-test-mongo-volume
test_mongo_db_name=outpost_api_test
test_mongo_db_user=outpost
test_mongo_db_password=password
test_mongo_init_db_user=admin
test_mongo_init_db_password=password
test_mongo_local_db_uri="mongodb://$(test_mongo_db_user):$(test_mongo_db_password)@localhost:$(test_mongo_port)/$(test_mongo_db_name)"
test_mongo_internal_db_uri="mongodb://$(test_mongo_db_user):$(test_mongo_db_password)@$(test_mongo_container_name):27017/$(test_mongo_db_name)"

test_postgres_container_name=outpost-test-postgres
test_postgres_port=5434
test_postgres_volume_name=outpost-test-postgres-volume
test_postgres_db_name=outpost_test
test_postgres_db_user=outpost
test_postgres_db_password=password
test_postgres_local_db_uri="postgresql://$(test_postgres_db_user):$(test_postgres_db_password)@localhost:$(test_postgres_port)/$(test_postgres_db_name)"
test_postgres_internal_db_uri="postgresql://$(test_postgres_db_user):$(test_postgres_db_password)@$(test_postgres_container_name):5432/outpost?"


prod_network_name=outpost-production-network
prod_container_name=outpost_production
prod_container_port=3000

prod_mongo_container_name=outpost-production-mongo
prod_mongo_port=27020
prod_mongo_volume_name=outpost-production-mongo-volume
prod_mongo_db_name=outpost_api_production
prod_mongo_db_user=outpost
prod_mongo_db_password=password
prod_mongo_init_db_user=admin
prod_mongo_init_db_password=password
prod_mongo_local_db_uri="mongodb://$(prod_mongo_db_user):$(prod_mongo_db_password)@localhost:$(prod_mongo_port)/$(prod_mongo_db_name)"
prod_mongo_internal_db_uri="mongodb://$(prod_mongo_db_user):$(prod_mongo_db_password)@$(prod_mongo_container_name):27017/$(prod_mongo_db_name)"


prod_postgres_container_name=outpost-test-postgres
prod_postgres_port=5435
prod_postgres_volume_name=outpost-production-postgres-volume
prod_postgres_db_name=outpost_production
prod_postgres_db_user=outpost
prod_postgres_db_password=password
prod_postgres_local_db_uri="postgresql://$(prod_postgres_db_user):$(prod_postgres_db_password)@localhost:$(prod_postgres_port)/$(prod_postgres_db_name)"
prod_postgres_internal_db_uri="postgresql://$(prod_postgres_db_user):$(prod_postgres_db_password)@$(prod_postgres_container_name):5432/outpost?"



help: ## Lists all documented Make targets.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m\make %-30s\033[0m %s\n", $$1, $$2}'
list: help



# ╔══════════════════════════════════╗
# ║          BUILD IMAGES            ║
# ╚══════════════════════════════════╝


build-dev-base: ## build the dev base image locally
	docker build --progress=plain -f .docker/images/dev-base/Dockerfile -t outpost-dev-base .

# --------------------

# nb: wont work on silicone macs (so untested)
build-test: ## build the test image
	docker build --progress=plain \
	--platform linux/amd64 \
	--build-arg NODE_OPTIONS=--openssl-legacy-provider \
	--build-arg NODE_ENV=development \
	--build-arg RAILS_ENV=test \
	-f "Dockerfile.test" \
	-t outpost:test "."

# --------------------

# nb: wont work on silicone macs (so untested)
build-prod:  ## build the production image 
	docker build --no-cache --progress=plain \
	--platform linux/amd64 \
	--build-arg TRACE=true \
	--build-arg NODE_OPTIONS=--openssl-legacy-provider \
	--build-arg NODE_ENV=production \
	--build-arg RAILS_ENV=production \
	-f "Dockerfile.production" \
	-t outpost:production "."

# ------------------------------------------------------------------------------


# ╔══════════════════════════════════╗
# ║          RUN IMAGES            	 ║
# ╚══════════════════════════════════╝

# example of the '/app/.docker/docker-entrypoint-migrate.sh' entrypoint to migrate then run the application
# you can also set the entrypoint to /start and the command to web or migrate_web to run the application
up-prod: ## Start the application as if it were in production
	make env-prod
	@if ! docker container ls -a | grep -q $(prod_container_name); then \
			docker run -it -d --name $(prod_container_name) \
			--platform linux/amd64 \
			--network $(prod_network_name) \
			--entrypoint /app/.docker/docker-entrypoint-migrate.sh \
			-p $(prod_container_port):3000/tcp \
			-e SECRET_KEY_BASE=dummy \
			-e DATABASE_URL=$(prod_postgres_internal_db_uri) \
			-e DB_URI=$(prod_mongo_internal_db_uri) \
			ghcr.io/wearefuturegov/outpost:latest web; \
			echo "Container $(prod_container_name) is now running"; \
	else \
			echo "Container $(prod_container_name) is already running"; \
	fi
	@echo "Don't forget to run ngrok! ngrok http $(prod_container_port)"

seed-prod: ## Seed production database
	make cmd-exec-prod cmd="bin/rails SEED_ADMIN_USER=true  SEED_DUMMY_DATA=true SEED_DEFAULT_DATA=true db:seed"

# /exec run command on the container as unprivileged user eg bin/rails c
cmd-exec-prod: ## execute a command as an unprivileged user on the application eg make cmd-exec-prod cmd="bin/rails c"
	@if [ -z "$(cmd)" ]; then echo "cmd is required"; exit 1; fi
	docker exec -it $(prod_container_name) /exec $(cmd)

# /start run any command from procfile eg web or migrate
# nb /start is the default entrypoint for the production image
cmd-start-prod: ## execute a command on the production image as if you were heroku eg make cmd-start-prod cmd="release"
	@if [ -z "$(cmd)" ]; then echo "cmd is required"; exit 1; fi
	docker exec -it $(prod_container_name) /start $(cmd)

start-prod:	## start prod environment
	@if ! docker container ls -a | grep -q $(prod_container_name); then \
			echo "Container $(prod_container_name) isn't running, nothing to start"; \
	else \
			docker container start $(prod_container_name); \
			echo "Container $(prod_container_name) is now started"; \
	fi

stop-prod:	## stop prod environment
	@if ! docker container ls -a | grep -q $(prod_container_name); then \
			echo "Container $(prod_container_name) isn't running, nothing to stop"; \
	else \
			docker container stop $(prod_container_name); \
			echo "Container $(prod_container_name) is now stopped"; \
	fi

rm-prod:	## remove prod environment
	@if ! docker container ls -a | grep -q $(prod_container_name); then \
			echo "Container $(prod_container_name) isn't running, nothing to remove"; \
	else \
			docker container stop $(prod_container_name); \
			docker container rm $(prod_container_name); \
			echo "Container $(prod_container_name) is now gone 💥"; \
	fi


# ╔══════════════════════════════════╗
# ║        SETUP ENVIRONMENT         ║
# ╚══════════════════════════════════╝


env-test: ## Start the test environment
	make env-test-setup
	make test-postgres
	make test-mongo

env-test-setup: ## Setup the test environment
	@if ! docker network ls | grep -q $(test_network_name); then \
			echo "Network $(test_network_name) does not exist, creating..."; \
			docker network create $(test_network_name); \
	else \
			echo "Network $(test_network_name) already exists."; \
	fi
	@if ! docker volume ls | grep -q $(test_postgres_volume_name); then \
			echo "Volume $(test_postgres_volume_name) does not exist, creating..."; \
			docker volume create $(test_postgres_volume_name); \
	else \
			echo "Volume $(test_postgres_volume_name) already exists."; \
	fi
	@if ! docker volume ls | grep -q $(test_mongo_volume_name); then \
			echo "Volume $(test_mongo_volume_name) does not exist, creating..."; \
			docker volume create $(test_mongo_volume_name); \
	else \
			echo "Volume $(test_mongo_volume_name) already exists."; \
	fi

env-test-clear: ## Remove the test environment
	@if ! docker network ls | grep -q $(test_network_name); then \
			echo "Network $(test_network_name) does not exist"; \
	else \
			echo "Network $(test_network_name) exists, deleting..."; \
			docker network rm $(test_network_name); \
	fi
	@if ! docker volume ls | grep -q $(test_postgres_volume_name); then \
			echo "Volume $(test_postgres_volume_name) does not exist"; \
	else \
			echo "Volume $(test_postgres_volume_name) exists, deleting..."; \
			docker volume rm $(test_postgres_volume_name); \
	fi
	@if ! docker volume ls | grep -q $(test_mongo_volume_name); then \
			echo "Volume $(test_mongo_volume_name) does not exist"; \
	else \
			echo "Volume $(test_mongo_volume_name) exists, deleting..."; \
			docker volume rm $(test_mongo_volume_name); \
	fi

# --------------------

env-prod: ## Start the prod environment
	make env-prod-setup
	make prod-postgres
	make prod-mongo

env-prod-setup: ## Setup the prod environment
	@if ! docker network ls | grep -q $(prod_network_name); then \
			echo "Network $(prod_network_name) does not exist, creating..."; \
			docker network create $(prod_network_name); \
	else \
			echo "Network $(prod_network_name) already exists."; \
	fi
	@if ! docker volume ls | grep -q $(prod_postgres_volume_name); then \
			echo "Volume $(prod_postgres_volume_name) does not exist, creating..."; \
			docker volume create $(prod_postgres_volume_name); \
	else \
			echo "Volume $(prod_postgres_volume_name) already exists."; \
	fi
	@if ! docker volume ls | grep -q $(prod_mongo_volume_name); then \
			echo "Volume $(prod_mongo_volume_name) does not exist, creating..."; \
			docker volume create $(prod_mongo_volume_name); \
	else \
			echo "Volume $(prod_mongo_volume_name) already exists."; \
	fi

env-prod-clear: ## Remove the prod environment
	@if ! docker network ls | grep -q $(prod_network_name); then \
			echo "Network $(prod_network_name) does not exist"; \
	else \
			echo "Network $(prod_network_name) exists, deleting..."; \
			docker network rm $(prod_network_name); \
	fi
	@if ! docker volume ls | grep -q $(prod_postgres_volume_name); then \
			echo "Volume $(prod_postgres_volume_name) does not exist"; \
	else \
			echo "Volume $(prod_postgres_volume_name) exists, deleting..."; \
			docker volume rm $(prod_postgres_volume_name); \
	fi
	@if ! docker volume ls | grep -q $(prod_mongo_volume_name); then \
			echo "Volume $(prod_mongo_volume_name) does not exist"; \
	else \
			echo "Volume $(prod_mongo_volume_name) exists, deleting..."; \
			docker volume rm $(prod_mongo_volume_name); \
	fi


# ------------------------------------------------------------------------------


# ╔══════════════════════════════════╗
# ║         SETUP POSTGRES           ║
# ╚══════════════════════════════════╝

test-postgres:  ## run postgres for the test environment
	make env-test-setup
	@if ! docker container ls -a | grep -q $(test_postgres_container_name); then \
			docker run -d --name $(test_postgres_container_name) \
			--network $(test_network_name) \
			-p $(test_postgres_port):5432 \
			-v $(test_postgres_volume_name):/var/lib/postgresql/data \
			-e POSTGRES_DB=$(test_postgres_db_name) \
			-e POSTGRES_PASSWORD=$(test_postgres_db_password) \
			-e POSTGRES_USER=$(test_postgres_db_user) \
			postgres:13.7-alpine; \
			echo "Container $(test_postgres_container_name) is now running"; \
	else \
			echo "Container $(test_postgres_container_name) is already running"; \
	fi
	@echo "Connect to it from your machine at: $(test_postgres_local_db_uri)"
	@echo "The DATABASE_URL connection string will be: $(test_postgres_internal_db_uri)"

test-postgres-stop:	## stop postgres for the test environment
	@if ! docker container ls -a | grep -q $(test_postgres_container_name); then \
			echo "Container $(test_postgres_container_name) isn't running, nothing to stop"; \
	else \
			docker container stop $(test_postgres_container_name); \
			echo "Container $(test_postgres_container_name) is now stopped"; \
	fi

test-postgres-rm:	## remove postgres for the test environment
	@if ! docker container ls -a | grep -q $(test_postgres_container_name); then \
			echo "Container $(test_postgres_container_name) isn't running, nothing to remove"; \
	else \
			docker container stop $(test_postgres_container_name); \
			docker container rm $(test_postgres_container_name); \
			echo "Container $(test_postgres_container_name) is now gone 💥"; \
	fi

# --------------------

prod-postgres:  ## run postgres for the prod environment
	make env-prod-setup
	@if ! docker container ls -a | grep -q $(prod_postgres_container_name); then \
			docker run -d --name $(prod_postgres_container_name) \
			--network $(prod_network_name) \
			-p $(prod_postgres_port):5432 \
			-v $(prod_postgres_volume_name):/var/lib/postgresql/data \
			-e POSTGRES_DB=$(prod_postgres_db_name) \
			-e POSTGRES_PASSWORD=$(prod_postgres_db_password) \
			-e POSTGRES_USER=$(prod_postgres_db_user) \
			postgres:13.7-alpine; \
			echo "Container $(prod_postgres_container_name) is now running"; \
	else \
			echo "Container $(prod_postgres_container_name) is already running"; \
	fi
	@echo "Connect to it from your machine at: $(test_postgres_local_db_uri)"
	@echo "The DATABASE_URL connection string will be: $(test_postgres_internal_db_uri)"


prod-postgres-stop:	## stop postgres for the prod environment
	@if ! docker container ls -a | grep -q $(prod_postgres_container_name); then \
			echo "Container $(prod_postgres_container_name) isn't running, nothing to stop"; \
	else \
			docker container stop $(prod_postgres_container_name); \
			echo "Container $(prod_postgres_container_name) is now stopped"; \
	fi

prod-postgres-rm:	## remove postgres for the prod environment
	@if ! docker container ls -a | grep -q $(prod_postgres_container_name); then \
			echo "Container $(prod_postgres_container_name) isn't running, nothing to remove"; \
	else \
			docker container stop $(prod_postgres_container_name); \
			docker container rm $(prod_postgres_container_name); \
			echo "Container $(prod_postgres_container_name) is now gone 💥"; \
	fi


# ------------------------------------------------------------------------------


# ╔══════════════════════════════════╗
# ║         SETUP MONGO              ║
# ╚══════════════════════════════════╝

test-mongo:  ## run postgres for the test environment
	make env-test-setup
	@if ! docker container ls -a | grep -q $(test_mongo_container_name); then \
			docker run -d --name $(test_mongo_container_name) \
			--platform=linux/arm64 \
			--network $(test_network_name) \
			-p $(test_mongo_port):27017 \
			-v $(test_mongo_volume_name):/data/db \
			-v "./.docker/services/mongo/setup-mongodb.js:/docker-entrypoint-initdb.d/mongo-init.js:ro" \
			-e MONGO_INITDB_ROOT_USERNAME=$(test_mongo_init_db_user) \
      -e MONGO_INITDB_ROOT_PASSWORD=$(test_mongo_init_db_password) \
      -e MONGO_INITDB_USERNAME=$(test_mongo_db_user) \
      -e MONGO_INITDB_PASSWORD=$(test_mongo_db_password) \
      -e MONGO_INITDB_DATABASE=$(test_mongo_db_name) \
			mongo:6; \
			echo "Container $(test_mongo_container_name) is now running"; \
	else \
			echo "Container $(test_mongo_container_name) is already running"; \
	fi
	@echo "Connect to it from your machine at: $(test_mongo_local_db_uri)"
	@echo "The DB_URI connection string will be: $(test_mongo_internal_db_uri)"

test-mongo-stop:	## stop mongo for the test environment
	@if ! docker container ls -a | grep -q $(test_mongo_container_name); then \
			echo "Container $(test_mongo_container_name) isn't running, nothing to stop"; \
	else \
			docker container stop $(test_mongo_container_name); \
			echo "Container $(test_mongo_container_name) is now stopped"; \
	fi

test-mongo-rm:	## remove mongo for the test environment
	@if ! docker container ls -a | grep -q $(test_mongo_container_name); then \
			echo "Container $(test_mongo_container_name) isn't running, nothing to remove"; \
	else \
			docker container stop $(test_mongo_container_name); \
			docker container rm $(test_mongo_container_name); \
			echo "Container $(test_mongo_container_name) is now gone 💥"; \
	fi

# --------------------

prod-mongo:  ## run postgres for the prod environment
	make env-prod-setup
	@if ! docker container ls -a | grep -q $(prod_mongo_container_name); then \
			docker run -d --name $(prod_mongo_container_name) \
			--platform=linux/arm64 \
			--network $(prod_network_name) \
			-p $(prod_mongo_port):27017 \
			-v $(prod_mongo_volume_name):/data/db \
			-v "./.docker/services/mongo/setup-mongodb.js:/docker-entrypoint-initdb.d/mongo-init.js:ro" \
			-e MONGO_INITDB_ROOT_USERNAME=$(prod_mongo_init_db_user) \
      -e MONGO_INITDB_ROOT_PASSWORD=$(prod_mongo_init_db_password) \
      -e MONGO_INITDB_USERNAME=$(prod_mongo_db_user) \
      -e MONGO_INITDB_PASSWORD=$(prod_mongo_db_password) \
      -e MONGO_INITDB_DATABASE=$(prod_mongo_db_name) \
			mongo:6; \
			echo "Container $(prod_mongo_container_name) is now running"; \
	else \
			echo "Container $(prod_mongo_container_name) is already running"; \
	fi
	@echo "Connect to it from your machine at: $(prod_mongo_local_db_uri)"
	@echo "The DB_URI connection string will be: $(prod_mongo_internal_db_uri)"

prod-mongo-stop:	## stop mongo for the prod environment
	@if ! docker container ls -a | grep -q $(prod_mongo_container_name); then \
			echo "Container $(prod_mongo_container_name) isn't running, nothing to stop"; \
	else \
			docker container stop $(prod_mongo_container_name); \
			echo "Container $(prod_mongo_container_name) is now stopped"; \
	fi

prod-mongo-rm:	## remove mongo for the prod environment
	@if ! docker container ls -a | grep -q $(prod_mongo_container_name); then \
			echo "Container $(prod_mongo_container_name) isn't running, nothing to remove"; \
	else \
			docker container stop $(prod_mongo_container_name); \
			docker container rm $(prod_mongo_container_name); \
			echo "Container $(prod_mongo_container_name) is now gone 💥"; \
	fi



# ------------------------------------------------------------------------------


# ╔══════════════════════════════════╗
# ║         DEVELOPMENT              ║
# ╚══════════════════════════════════╝
# some helpers when developing locally 

dev-up: ## run local development environment
	docker compose up -d

dev-build: ## build local image
	docker compose build

dev-down: ## remove all local containers
	docker compose down

dev-seed: ## seed the local database with send_needs etc
	docker compose exec outpost bin/rails db:seed

dev-seed-admin: ## seed local database with send_needs etc and an admin user
	docker compose exec outpost bin/rails SEED_ADMIN_USER=true db:seed

dev-seed-data: ## seed local database with dummy data
	docker compose exec outpost bin/rails SEED_DUMMY_DATA=true db:seed

dev-seed-default-data: ## seed local database with send_needs etc
	docker compose exec outpost bin/rails SEED_DEFAULT_DATA=true db:seed

dev-seed-all: ## seed local database with admin user, dummy data and send_needs etc
	docker compose exec outpost bin/rails SEED_ADMIN_USER=true  SEED_DUMMY_DATA=true SEED_DEFAULT_DATA=true db:seed

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

dev-index: ## populate the api
	docker compose exec outpost bin/rails build_public_index 
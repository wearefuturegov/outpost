.PHONY: help
# Make stuff

-include .env

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

.DEFAULT_GOAL := help

ARTIFACTS_DIRECTORY := "./environment/artifacts"

CURRENT_PATH :=${abspath .}

SHELL_CONTAINER_NAME := $(if $(c),$(c),ruby)
BUILD_TARGET := $(if $(t),$(t),development)

help: ## Help.
	@grep -E '^[a-zA-Z-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "[32m%-27s[0m %s\n", $$1, $$2}'

build: ## Build images.
	@make copy_gem_files
	@make copy_node_files
	@docker-compose -f docker-compose.$(BUILD_TARGET).yml build

start: ## Start previously builded application images.
	@make create_project_artifacts
	@make start_postgres
	@make start_ruby
	@make start_nginx

stop: ## Stop all images.
	@docker-compose -f docker-compose.$(BUILD_TARGET).yml stop

shell: ## Internal image bash command line.
	@if [[ -z `docker ps | grep ${SHELL_CONTAINER_NAME}` ]]; then \
		echo "${SHELL_CONTAINER_NAME} is NOT running (make start)."; \
	else \
		docker-compose -f docker-compose.$(BUILD_TARGET).yml exec $(SHELL_CONTAINER_NAME) /bin/ash; \
	fi

rails_console: ## Internal image bash command line.
	@if [[ -z `docker ps | grep ${SHELL_CONTAINER_NAME}` ]]; then \
		echo "${SHELL_CONTAINER_NAME} is NOT running (make start)."; \
	else \
		docker-compose -f docker-compose.$(BUILD_TARGET).yml exec $(SHELL_CONTAINER_NAME) rails console; \
	fi

run: ## run outpost
	@docker-compose -f docker-compose.$(BUILD_TARGET).yml exec ruby /bin/ash /rdebug_ide/runner.sh

create_project_artifacts: 
	mkdir -p ./environment/artifacts/rails
	mkdir -p ./environment/artifacts/db

copy_gem_files: ## copy gemfiles to artifacts
	@make create_project_artifacts
	@cp ${APP_PATH}/Gemfile "${ARTIFACTS_DIRECTORY}/rails/Gemfile"
	@cp ${APP_PATH}/Gemfile.lock "${ARTIFACTS_DIRECTORY}/rails/Gemfile.lock"

copy_node_files: ## copy node files to artifacts
	@make create_project_artifacts
	@cp ${APP_PATH}/package.json "${ARTIFACTS_DIRECTORY}/rails/package.json"
	@cp ${APP_PATH}/yarn.lock "${ARTIFACTS_DIRECTORY}/rails/yarn.lock"

start_postgres: ## Start postgres image.
	@if [[ -z `docker ps | grep postgres` ]]; then \
		docker-compose -f docker-compose.$(BUILD_TARGET).yml up -d postgres; \
	else \
		echo "Postgres is running."; \
	fi

start_ruby: ## Start ruby image.
	@if [[ -z `docker ps | grep ruby` ]]; then \
		docker-compose -f docker-compose.$(BUILD_TARGET).yml up -d ruby; \
	else \
		echo "Ruby is running."; \
	fi

start_nginx: ## Start nginx image.
	@if [[ -z `docker ps | grep nginx` ]]; then \
		docker-compose -f docker-compose.$(BUILD_TARGET).yml up -d nginx; \
	else \
		echo "Nginx is running."; \
	fi

# docker-compose -f docker-compose.$(BUILD_TARGET).yml up -d nginx
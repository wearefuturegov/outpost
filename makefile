.PHONY: help
# Make stuff

-include .env

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

.DEFAULT_GOAL := help

ARTIFACTS_DIRECTORY := "./environment/artifacts"

CURRENT_PATH :=${abspath .}

SHELL_CONTAINER_NAME := $(if $(c),$(c),outpost)
BUILD_TARGET := $(if $(t),$(t),development)

help: ## Help.
	@grep -E '^[a-zA-Z-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "[32m%-27s[0m %s\n", $$1, $$2}'

install: ## Install
	@make build
	@make start
	@docker-compose -f docker-compose.$(BUILD_TARGET).yml exec outpost-api npm run prepare-indices;
	@docker-compose -f docker-compose.$(BUILD_TARGET).yml exec outpost rails db:migrate RAILS_ENV=development;
	@docker-compose -f docker-compose.$(BUILD_TARGET).yml exec outpost rails db:seed; 

build: ## Build images.
	@docker-compose -f docker-compose.$(BUILD_TARGET).yml build

start: ## Start containers
	@docker-compose -f docker-compose.$(BUILD_TARGET).yml up -d 

run: ## Run Outpost
	@docker-compose -f docker-compose.$(BUILD_TARGET).yml exec outpost /bin/ash /rdebug_ide/runner.sh

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

build_public_index: ## Build images.
	@docker-compose -f docker-compose.$(BUILD_TARGET).yml exec outpost rake build_public_index
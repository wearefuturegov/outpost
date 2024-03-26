APP_NAME?=outpost
IMAGE_NAME?="$(APP_NAME):latest"

export DOCKER_BUILDKIT = 1

up: build
	docker run -t -i \
		-e PORT=3000 \
		-p 3000:3000/tcp \
		$(IMAGE_NAME)

pull:
	docker pull gliderlabs/herokuish

build: pull
	docker build -f Dockerfile.production --build-arg NPM_TOKEN -t $(IMAGE_NAME) .

build-osx: pull
	docker build --platform linux/amd64 -f Dockerfile.production --build-arg NPM_TOKEN -t $(IMAGE_NAME) .

debug: build
	docker run -t -i --entrypoint /bin/bash $(IMAGE_NAME)

tests: build
	docker run -t -i --entrypoint /bin/bash $(IMAGE_NAME) buildpack test 

tests-osx: build-osx
	docker run --platform linux/amd64 --rm -v .:/tmp/app gliderlabs/herokuish /bin/herokuish buildpack test 

dev-up:
	docker compose up -d

dev-down:
	docker compose down

dev-seed-admin:
	docker compose exec outpost bin/rails SEED_ADMIN_USER=true db:seed

dev-seed:
	docker compose exec outpost bin/rails SEED_DUMMY_DATA=true db:seed

dev-ssh:
	docker compose exec outpost bash

dev-railsc:
	docker compose exec outpost bin/rails c

dev-tests:
	# docker compose exec outpost bash -c "DISABLE_SPRING=1 NODE_ENV=development RAILS_ENV=test bundle exec rspec ./spec/features/filtering_services_spec.rb:64"
	# docker compose exec outpost bash -c "DISABLE_SPRING=1 NODE_ENV=development RAILS_ENV=test bundle exec rspec ./spec/features/test_for_tests.rb"
	docker compose exec outpost bash -c "DISABLE_SPRING=1 NODE_ENV=development RAILS_ENV=test bundle exec rspec"

dev-rake:
	docker compose exec outpost bash -c "DISABLE_SPRING=1 NODE_ENV=development RAILS_ENV=test rake"

dev-coverage:
	open coverage/index.html
# This Dockerfile is for development and testing purposes ONLY it is not suitable for production use.
# This is because in production we use buildpacks to create a slug of the application and run that slug in a container.
# This replicates our setup in heroku and is the best way to ensure that the application runs as expected in production 
# and that we have a reliable development environment

# If you need to leave the container running for example to debug something switch out the init command with 
# CMD ["tail", "-f", "/dev/null"]

# if your using these values anywhere new see https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
# we don't set any defaults here on purpose as we will mostly use this as a development environment not setting an env value lets us run tests in the container easily
ARG NODE_ENV
ARG RAILS_ENV

# ----------------------------------------------------------------
FROM ghcr.io/wearefuturegov/outpost-dev-base:latest as install

# make this stage non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Switch back to the root user for a second to install some packages
USER root
RUN apt-get update --error-on=any
# for pg gem
RUN apt-get install -y \
  libpq-dev \
  postgresql
USER outpost-user

# set $HOME to outpost-user path for this non-interactive session
ENV HOME /home/outpost-user
ENV PATH $HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH

WORKDIR /usr/src/app

COPY --chown=outpost-user:outpost-user ./.ruby-version ./.ruby-version
COPY --chown=outpost-user:outpost-user ./Gemfile ./Gemfile
COPY --chown=outpost-user:outpost-user ./Gemfile.lock ./Gemfile.lock
COPY --chown=outpost-user:outpost-user ./package.json ./package.json
COPY --chown=outpost-user:outpost-user ./yarn.lock ./yarn.lock
COPY --chown=outpost-user:outpost-user ./.docker/bin/check-versions.sh ./.docker/bin/check-versions.sh

RUN ls -lah
RUN pwd

# check everything is all good
RUN ./.docker/bin/check-versions.sh

# set the environment variables
ARG NODE_ENV
ARG RAILS_ENV
ENV NODE_ENV=${NODE_ENV}
ENV RAILS_ENV=${RAILS_ENV}

# -------------
# install gems
# -------------

# throw errors if Gemfile has been modified since Gemfile.lock
RUN if [ "${RAILS_ENV}" = "production" ]; then \
  bundle config --global frozen 1; fi

RUN if [ "${RAILS_ENV}" = "development" ] || [ -z "${RAILS_ENV}" ]; then \
  bundle install --verbose; fi
RUN if [ "${RAILS_ENV}" = "production" ]; then \
  bundle config set --local deployment 'true' && bundle install; fi


# -------------
# install node modules
# -------------
RUN if [ "${NODE_ENV}" = "development" ] || [ -z "${NODE_ENV}" ]; then \
  yarn install; fi
RUN if [ "${NODE_ENV}" = "production" ]; then \
  yarn install --frozen-lockfile; fi

RUN if [ "${APP_ENV}" = "production" ]; then \
  NODE_OPTIONS=--openssl-legacy-provider SECRET_KEY_BASE=dummyvalue bundle exec rails assets:precompile; fi


# after this point we don't need to be non-interactive anymore since we'll be running the container
ENV DEBIAN_FRONTEND=

EXPOSE 3000

ENTRYPOINT [".docker/docker-entrypoint.sh"]
CMD ["bin/rails", "s", "-u", "puma", "-p", "3000", "-b=0.0.0.0"]
# CMD ["bin/bundle", "exec", "puma", "-C", "config/puma.rb"]
# CMD ["tail", "-f", "/dev/null"]
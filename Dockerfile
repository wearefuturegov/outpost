# ========================================================
# This Dockerfile is for DEVELOPMENT and TESTING purposes 
# ONLY it is not suitable for production use!!
# It will however let you 'run' the app in production mode 
# if you want to test things like asset precompilation
# ========================================================


# if your using these values anywhere new see 
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG NODE_ENV=development
ARG RAILS_ENV=development
ARG NODE_VERSION=20.11.0
ARG YARN_VERSION=1.22.22
ARG BUNDLER_VERSION=2.6.9


FROM ruby:3.1.7-bookworm@sha256:91627f55e8969006aab67d15c92fb930500ff73948803da1330b8a853fecebb5 AS build

SHELL ["/bin/bash", "-c"]

ARG NODE_ENV
ARG RAILS_ENV
ARG NODE_VERSION
ARG YARN_VERSION
ARG BUNDLER_VERSION

# copy over key for installing latest postgreSQL client
COPY .docker/services/outpost/postgresql-ACCC4CF8.asc /tmp

# make sure everything installs where we can access it
RUN export GEM_HOME=/home/outpost-user/gems
ENV GEM_HOME=/home/outpost-user/gems
ENV BUNDLE_PATH=/home/outpost-user/bundle
ENV PATH=$GEM_HOME/bin:$PATH
RUN export PATH="$GEM_HOME/bin:$PATH"

# apt-utils \
# Set up environment and install base packages
RUN set -euxo pipefail && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -qq && \
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
    apt-get install -y --no-install-recommends \
      curl \
      git \
      jq \
      locales \
      libvips-dev \
      poppler-utils \
      libpq-dev \
      wget \
      gnupg \
      chromium \
      chromium-driver \
    && locale-gen && \
    # Add PostgreSQL repo and install latest client
    echo 'deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main' > /etc/apt/sources.list.d/pgdg.list && \
    apt-key add /tmp/postgresql-ACCC4CF8.asc && \
    apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client-16 && \
    # Clean up apt cache to reduce image size
    rm -rf /var/lib/apt/lists/* /root/* /tmp/* /var/cache/apt/archives/*.deb


# Install Node.js & Yarn
ENV PATH=/usr/local/node/bin:$PATH
RUN set -euxo pipefail && \
    curl --retry 5 --retry-delay 5 --retry-max-time 60 -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

# Install Bundler
# gem update --system && 
RUN gem install bundler -v $BUNDLER_VERSION

# Create a non admin user 
RUN groupadd outpost-user --gid 1000
RUN useradd outpost-user --uid 1000 --gid 1000 --shell /bin/bash --create-home

RUN mkdir /home/outpost-user/.cache 
RUN chown -R outpost-user:outpost-user /home/outpost-user
RUN mkdir /app && chown -R outpost-user:outpost-user /app
USER outpost-user
RUN mkdir -p /app/node_modules /app/tmp && chown -R outpost-user:outpost-user /app/node_modules /app/tmp

WORKDIR /app

# don't bake in env vars
RUN export NODE_ENV="$NODE_ENV"
RUN export RAILS_ENV="$RAILS_ENV"
# ENV NODE_ENV=${NODE_ENV}
# ENV RAILS_ENV=${RAILS_ENV}

COPY --chown=outpost-user:outpost-user ./.ruby-version ./.ruby-version
COPY --chown=outpost-user:outpost-user ./Gemfile ./Gemfile
COPY --chown=outpost-user:outpost-user ./Gemfile.lock ./Gemfile.lock
COPY --chown=outpost-user:outpost-user ./package.json ./package.json
COPY --chown=outpost-user:outpost-user ./yarn.lock ./yarn.lock

# install javascript
RUN yarn install

# install packages
RUN bundle check || bundle install

EXPOSE 3000

CMD ["bin/dev"]


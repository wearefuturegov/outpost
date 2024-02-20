# By default image is built using RAILS_ENV=production.
# You may want to customize it:
#
#   --build-arg RAILS_ENV=development
#
#
# If you need to leave the container running for example to debug something switch out the init command with 
# CMD ["tail", "-f", "/dev/null"]


# if your using these values anywhere new see https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG NODE_VERSION=20.9.0
ARG RUBY_VERSION=3.0.3
ARG BUNDLER_VERSION=2.3.25
ARG YARN_VERSION=1.22.19
ARG NODE_ENV=production
ARG RAILS_ENV=production
ARG RACK_ENV=production
ARG APP_ENV=production

#
#  FROM: node
#
FROM node:$NODE_VERSION-alpine AS node
# used to make the image publically available on github
LABEL org.opencontainers.image.source="https://github.com/wearefuturegov/outpost" 

ARG RUBY_VERSION
ARG BUNDLER_VERSION
ARG YARN_VERSION
ARG NODE_ENV
ARG RAILS_ENV
ARG RACK_ENV
ARG APP_ENV

#
#  FROM: base_image
#
FROM ruby:$RUBY_VERSION-alpine as base_image

ARG RUBY_VERSION
ARG BUNDLER_VERSION
ARG YARN_VERSION
ARG NODE_ENV
ARG RAILS_ENV
ARG RACK_ENV
ARG APP_ENV

# 'install' specific node version https://medium.com/geekculture/how-to-install-a-specific-node-js-version-in-an-alpine-docker-image-3edc1c2c64be
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin
COPY --from=node /opt /opt

# gcompat is for nokogiri - alpine doesnt include glibc it needs https://nokogiri.org/tutorials/installing_nokogiri.html#linux-musl-error-loading-shared-library
# python3 for node-sass drama
RUN apk update && apk upgrade && apk add --no-cache git \
  build-base \
  libpq-dev \
  tzdata \
  gcompat \
  python3 \
  postgresql-client \
  openssl 

# install bundler version
RUN gem install bundler:$BUNDLER_VERSION

# Add a user for later
RUN adduser -D outpost-user

WORKDIR /usr/build/app


COPY ./Gemfile /usr/build/app/Gemfile
COPY ./Gemfile.lock /usr/build/app/Gemfile.lock
COPY ./package.json /usr/build/app/package.json
COPY ./yarn.lock /usr/build/app/yarn.lock


ENV RAILS_ENV=${RAILS_ENV}

# throw errors if Gemfile has been modified since Gemfile.lock
RUN if [ "${RAILS_ENV}" == "production" ]; then \
  bundle config --global frozen 1; fi

EXPOSE 3000

#
#  FROM: install
#
FROM base_image as install

ARG NODE_ENV
ARG RAILS_ENV
ARG RACK_ENV
ARG APP_ENV

ENV NODE_ENV=${NODE_ENV}
ENV RAILS_ENV=${RAILS_ENV}
ENV RACK_ENV=${RACK_ENV}
ENV APP_ENV=${APP_ENV}

RUN bundle install

RUN if [ "${NODE_ENV}" == "development" ]; then \
  yarn install; fi
RUN if [ "${NODE_ENV}" == "production" ]; then \
  yarn install --frozen-lockfile; fi



#
#  FROM: createinit
#
FROM install as basics
ARG NODE_ENV
ARG RAILS_ENV
ARG RACK_ENV
ARG APP_ENV

ENV NODE_ENV=${NODE_ENV}
ENV RAILS_ENV=${RAILS_ENV}
ENV RACK_ENV=${RACK_ENV}
ENV APP_ENV=${APP_ENV}

WORKDIR /usr/src/app
COPY --chown=outpost-user:outpost-user ./environment/docker-run.sh /usr/run/app/init.sh
RUN chmod +x /usr/run/app/init.sh
COPY --chown=outpost-user:outpost-user --from=install /usr/build/app /usr/src/app


#
#  FROM: development
#
FROM basics as development
WORKDIR /usr/src/app
# USER outpost-user
CMD ["/usr/run/app/init.sh"]

#
#  FROM: test
#
FROM basics as test
RUN apk update && apk upgrade && apk add --no-cache chromium chromium-chromedriver python3 python3-dev py3-pip
COPY --chown=outpost-user:outpost-user ./environment/docker-test.sh /usr/run/app/init.sh
RUN chmod +x /usr/run/app/init.sh
WORKDIR /usr/src/app
# COPY --chown=outpost-user:outpost-user . /usr/src/app
RUN NODE_OPTIONS=--openssl-legacy-provider SECRET_KEY_BASE=dummyvalue bundle exec rails assets:precompile
RUN chown -R outpost-user:outpost-user /usr/src/app
USER outpost-user
# CMD ["/usr/run/app/init.sh"]
CMD ["tail", "-f", "/dev/null"]


#
#  FROM: production
#
FROM basics as production

WORKDIR /usr/src/app
COPY --chown=outpost-user:outpost-user . /usr/src/app

RUN NODE_OPTIONS=--openssl-legacy-provider SECRET_KEY_BASE=dummyvalue bundle exec rails assets:precompile
RUN chown -R outpost-user:outpost-user /usr/src/app
USER outpost-user
CMD ["/usr/run/app/init.sh"]
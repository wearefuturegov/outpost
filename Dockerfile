# using docker image layers to save waiting for things to rebuild all the time
# If you need to leave the container running for example to debug something switch out the init command with 
# CMD ["tail", "-f", "/dev/null"]


# if your using these values anywhere new see https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG NODE_VERSION=16.13.1
ARG RUBY_VERSION=3.0.3
ARG BUNDLER_VERSION=2.3.10
ARG YARN_VERSION=1.22.17


FROM node:$NODE_VERSION-alpine AS node
# used to make the image publically available on github
LABEL org.opencontainers.image.source="https://github.com/wearefuturegov/outpost"
ARG RUBY_VERSION
ARG BUNDLER_VERSION
ARG YARN_VERSION


FROM ruby:$RUBY_VERSION-alpine as base_image
ARG BUNDLER_VERSION
ARG YARN_VERSION

# 'install' specific node version https://medium.com/geekculture/how-to-install-a-specific-node-js-version-in-an-alpine-docker-image-3edc1c2c64be
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin
COPY --from=node /opt /opt

# Add a user for later
RUN adduser -D outpost-user

# gcompat is for nokogiri - alpine doesnt include glibc it needs https://nokogiri.org/tutorials/installing_nokogiri.html#linux-musl-error-loading-shared-library
# python3 for node-sass drama
RUN apk add --no-cache git \
  build-base \
  libpq-dev \
  tzdata \
  gcompat \
  python3

# install bundler version
RUN gem install bundler:$BUNDLER_VERSION



WORKDIR /usr/build/app
COPY ./Gemfile /usr/build/app/Gemfile
COPY ./Gemfile.lock /usr/build/app/Gemfile.lock
COPY ./package.json /usr/build/app/package.json
COPY ./yarn.lock /usr/build/app/yarn.lock
# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
EXPOSE 3000


FROM base_image as development_base
RUN bundle install
RUN yarn install


FROM base_image as production_base
RUN bundle install
RUN yarn install --frozen-lockfile

#  build and install all the things for the development env
FROM development_base as development
ENV NODE_ENV development
ENV RAILS_ENV development

WORKDIR /usr/src/app
COPY --chown=outpost-user:outpost-user ./environment/docker-run-development.sh /usr/run/app/init.sh
RUN chmod +x /usr/run/app/init.sh
COPY --chown=outpost-user:outpost-user --from=development_base /usr/build/app /usr/src/app
USER outpost-user
CMD ["/usr/run/app/init.sh"]
# CMD ["tail", "-f", "/dev/null"]


#  build and install all the things for the development env
FROM production_base as production
ENV NODE_ENV production
ENV RAILS_ENV production

WORKDIR /usr/src/app
COPY --chown=outpost-user:outpost-user ./environment/docker-run-production.sh /usr/run/app/init.sh
RUN chmod +x /usr/run/app/init.sh
COPY --chown=outpost-user:outpost-user --from=production_base /usr/build/app /usr/src/app
COPY --chown=outpost-user:outpost-user . /usr/src/app
USER outpost-user
CMD ["/usr/run/app/init.sh"]
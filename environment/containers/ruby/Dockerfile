# using docker image layers to save waiting for things to rebuild all the time
# base_image > build_rails > build_frontend > development


FROM ruby:3.0.5-alpine as base_image
RUN apk add --no-cache git \
    build-base \
    libpq-dev \
    tzdata \
    gcompat \
    python3 

# gcompat is for nokogiri - alpine doesnt include glibc it needs https://nokogiri.org/tutorials/installing_nokogiri.html#linux-musl-error-loading-shared-library
# python2 for node-sass drama

# install node v16
# see here for reference https://github.com/timbru31/docker-ruby-node/blob/master/3.0/16/alpine/Dockerfile
RUN apk -U upgrade \
  && apk add --repository https://dl-cdn.alpinelinux.org/alpine/v3.16/main/ --no-cache \
    "nodejs<18" \
  && apk add --no-cache \
    npm \
    yarn

# install various gems
FROM base_image as build_rails
COPY ./environment/artifacts/rails/Gemfile /tmp/Gemfile
COPY ./environment/artifacts/rails/Gemfile.lock /tmp/Gemfile.lock
RUN cd /tmp && \
  bundle install && \
  bundle exec rails webpacker:install && \
  apk add --no-cache git
WORKDIR /app

ENTRYPOINT ["tail", "-f", "/dev/null"]


# might need other dotfiles here at some point
FROM build_rails as build_frontend
COPY ./environment/artifacts/rails/package.json /tmp/package.json
COPY ./environment/artifacts/rails/yarn.lock /tmp/yarn.lock
RUN cd /tmp && \
  yarn install

ENTRYPOINT ["tail", "-f", "/dev/null"]




#  build and install all  the things for the development env
FROM build_frontend as development
COPY ./environment/containers/ruby/runners/runner.development.sh /rdebug_ide/runner.sh
RUN cd /tmp && \
  gem install ruby-debug-ide && \
  gem install debase && \
  chmod +x /rdebug_ide/runner.sh
WORKDIR /app

ENTRYPOINT ["tail", "-f", "/dev/null"]
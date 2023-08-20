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
FROM base_image as build_app
COPY ./Gemfile /tmp/Gemfile
COPY ./Gemfile.lock /tmp/Gemfile.lock
COPY ./package.json /tmp/package.json
COPY ./yarn.lock /tmp/yarn.lock

RUN cd /tmp && \
  bundle install && \
  yarn install && \
  apk add --no-cache git



WORKDIR /app

FROM build_app as base_env
COPY --from=build_app /tmp .


#  build and install all  the things for the development env
FROM base_env as development
COPY ./environment/docker-run-development.sh /rdebug_ide/runner.sh
RUN gem install ruby-debug-ide && \
  chmod +x /rdebug_ide/runner.sh

ENV RAILS_ENV="development" \
  NODE_ENV="development" \
  RAILS_SERVE_STATIC_FILES="false" 
EXPOSE 3000
# ENTRYPOINT ["tail", "-f", "/dev/null"]
CMD ["/rdebug_ide/runner.sh"]
# CMD bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -u puma -p 3000 -b '0.0.0.0'"
# ENTRYPOINT ["tail", "-f", "/dev/null"]


FROM base_env as test
COPY ./environment/docker-run-production.sh /runner/runner.sh
COPY . .
RUN chmod +x /runner/runner.sh
RUN bundle exec rails assets:precompile
EXPOSE 3000
ENV RAILS_ENV="test" \
    NODE_ENV="test" \
    RAILS_SERVE_STATIC_FILES="true" 
CMD ["/runner/runner.sh"]

#  build and install all  the things for the production env
FROM base_env as production
COPY ./environment/docker-run-production.sh /runner/runner.sh
COPY . .
RUN chmod +x /runner/runner.sh
EXPOSE 3000

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    RAILS_SERVE_STATIC_FILES="true" 

# ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/runner/runner.sh"]
# ENTRYPOINT ["/usr/bin/tini", "--"]
# CMD bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -u puma -p 3000 -b '0.0.0.0'"
# ENTRYPOINT ['./environment/docker-run-production.sh']
# CMD ["rails", "s", "-p", "3000"]
# ENTRYPOINT ["tail", "-f", "/dev/null"]


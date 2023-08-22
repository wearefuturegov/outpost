# using docker image layers to save waiting for things to rebuild all the time
# base_image > build_rails > build_frontend > development


FROM ruby:3.0.5-alpine as base_image
RUN adduser -D outpost-user

# gcompat is for nokogiri - alpine doesnt include glibc it needs https://nokogiri.org/tutorials/installing_nokogiri.html#linux-musl-error-loading-shared-library
# python3 for node-sass drama
RUN apk add --no-cache git \
  build-base \
  libpq-dev \
  tzdata \
  gcompat \
  python3

# install node v16
# see here for reference https://github.com/timbru31/docker-ruby-node/blob/master/3.0/16/alpine/Dockerfile
RUN apk -U upgrade \
  && apk add --repository https://dl-cdn.alpinelinux.org/alpine/v3.16/main/ --no-cache \
  "nodejs<18" \
  && apk add --no-cache \
  npm \
  yarn


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

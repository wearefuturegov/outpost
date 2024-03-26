#
# This Dockerfile is for DEVELOPMENT and TESTING purposes ONLY it is not suitable for production use, its huge and has a lot of unnecessary packages!
#
# If you don't have an M* mac you probably don't need to use this but it might make setting things up a little easier for you
#
# We're using heroku in production and which uses slugs 🐌 and buildpacks run in a container this solution gives us as close to that environment as possible locally; 
# an ubuntu environment based off the currently used heroku stack with the same versions of node, ruby, yarn, bundler that we're given inside heroku


# If you need to leave the container running for example to debug something you can use the following command to keep it running
# CMD ["tail", "-f", "/dev/null"]

# if your using these values anywhere new see https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
# we don't set any defaults here on purpose as we will mostly use this as a development environment not setting an env value lets us run tests in the container easily
ARG NODE_ENV=development
ARG RAILS_ENV=development

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

# for chrome for tests
RUN apt-get install -y \
  gconf-service \
  libappindicator1 \
  libasound2 \
  libatk1.0-0 \
  libatk-bridge2.0-0 \
  libcairo-gobject2 \
  libdrm2 \
  libgbm1 \
  libgconf-2-4 \
  libgtk-3-0 \
  libnspr4 \
  libnss3 \
  libx11-xcb1 \
  libxcb-dri3-0 \
  libxcomposite1 \
  libxcursor1 \
  libxdamage1 \
  libxfixes3 \
  libxi6 \
  libxinerama1 \
  libxrandr2 \
  libxshmfence1 \
  libxss1 \
  libxtst6 \
  fonts-liberation \
  jq


# Fetch the latest version numbers and URLs for Chrome and ChromeDriver
RUN curl -s https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json > /tmp/versions.json

# chrome
RUN CHROME_URL=$(jq -r '.channels.Stable.downloads.chrome[] | select(.platform=="linux64") | .url' /tmp/versions.json) && \
  wget -q --continue -O /tmp/chrome-linux64.zip $CHROME_URL && \
  unzip -j /tmp/chrome-linux64.zip -d /opt/chrome

RUN chmod +x /opt/chrome/chrome

# chromedriver
RUN CHROMEDRIVER_URL=$(jq -r '.channels.Stable.downloads.chromedriver[] | select(.platform=="linux64") | .url' /tmp/versions.json) && \
  wget -q --continue -O /tmp/chromedriver-linux64.zip $CHROMEDRIVER_URL && \
  unzip -j /tmp/chromedriver-linux64.zip -d /opt/chromedriver && \
  chmod +x /opt/chromedriver/chromedriver

# Clean up
RUN rm /tmp/chrome-linux64.zip /tmp/chromedriver-linux64.zip /tmp/versions.json

ENV PATH /opt/chrome:/opt/chromedriver:$PATH
RUN echo 'export PATH="/opt/chrome:/opt/chromedriver:$PATH"' >> ~/.bashrc

# Check chrome & chromedriver versions
RUN echo "Chrome: " && chrome --version
RUN echo "Chromedriver: " && chromedriver --version

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
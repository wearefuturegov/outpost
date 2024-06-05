# Because we want to be as close to the 'production' environment as possible when developing/running tests we base our dev environment on the heroku stack.
# Currently heroku-20 is based on ubuntu 20.04 which doesn't have the ruby version we need in the package manager so we need to build a base image first
# we only do this once and then we can use the image for development and testing purposes.
# ideally in the future when we're no longer using 3.0.3 this wont be necessary

# If you need to leave the container running for example to debug something switch out the init command with 
# CMD ["tail", "-f", "/dev/null"]

# if your using these values anywhere new see https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact

ARG HEROKU_STACK=20
ARG YARN_VERSION=1.22.19
ARG NODE_VERSION=20.9.0
ARG RUBY_VERSION=3.0.3
ARG BUNDLER_VERSION=2.3.25

# ----------------------------------------------------------------
# using heroku as our base since we run the production apps on heroku
FROM heroku/heroku:$HEROKU_STACK

ARG NODE_VERSION
ARG RUBY_VERSION
ARG BUNDLER_VERSION

# make this stage non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# updates
RUN apt-get update --error-on=any


# install dependencies for node install
RUN apt-get install -y \
  ca-certificates \
  curl


# install dependencies for ruby install
RUN apt-get install -y autoconf \
  patch \
  build-essential \
  rustc \
  libssl-dev \
  libyaml-dev \
  libreadline6-dev \
  zlib1g-dev \
  libgmp-dev \
  libncurses5-dev \
  libffi-dev \
  libgdbm6 \
  libgdbm-dev \
  libdb-dev \
  uuid-dev 

# -------------
# install node
# -------------

# install specific node version from prepackaged binaries
ARG NODE_PACKAGE=node-v$NODE_VERSION-linux-x64
ARG NODE_HOME=/opt/$NODE_PACKAGE
ENV NODE_PATH $NODE_HOME/lib/node_modules
ENV PATH $NODE_HOME/bin:$PATH
RUN curl https://nodejs.org/dist/v$NODE_VERSION/$NODE_PACKAGE.tar.gz | tar -xzC /opt/
# enable yarn
RUN corepack enable

# -------------
# install ruby & bundler version
# -------------

# Create a non-root user
RUN useradd -m outpost-user

# Switch to the new user
USER outpost-user

# ubuntu ruby-build package is too old to get the version we need so we're adding it here
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
  echo 'export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"' >> ~/.bashrc && \
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build


# $HOME is set in the shell but not in docker
ENV HOME /home/outpost-user
ENV PATH $HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH

RUN rbenv install $RUBY_VERSION 
RUN rbenv global $RUBY_VERSION

# install bundler 
RUN gem install bundler:$BUNDLER_VERSION

# after this point we don't need to be non-interactive anymore since we'll be running the container
ENV DEBIAN_FRONTEND=


# CMD ["tail", "-f", "/dev/null"]

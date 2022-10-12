# Select reference image
FROM ruby:3.0.3-alpine

# Install what we need and update image
RUN apk add \
  build-base \
  postgresql-dev \
  tzdata \
  nodejs

# Create app directory
WORKDIR /app

# copy gemfile from host to current directory (/app) in destination
COPY Gemfile* .

# because trouble
RUN gem install bundler -v 2.3.9

# install things
RUN bundle _2.3.9_ install

# copy all the rest of the files
COPY . .

# tells docker that the application will be listening on port 3000
EXPOSE 3000

# main entry point run whenever container is created
CMD ["rails", "server", "-b", "0.0.0.0"]
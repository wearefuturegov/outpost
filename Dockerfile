# using a multistage build to reduce filesize
# https://earthly.dev/blog/docker-multistage/
# dockerfile contains multiple steps - dependencies done first, then application
# then only the files necessary to run the application are included in the final stage

# use official ruby image only has 3.0.0 and 3.0.5 (we're using 3.0.3)
# alpine is a smaller image (alpine uses apk)

# build the dependencies
FROM ruby:3.0.5-alpine AS builder

RUN apk add \
  build-base \
  postgresql-dev

# Copy files from host to docker image
# . == current directory
COPY Gemfile* .


RUN gem install bundler:2.4.3

# install gems
RUN bundle install

# build the application
FROM ruby:3.0.5-alpine AS runner


# install node etc since rails needs it
RUN apk add \
    tzdata \
    nodejs \
    postgresql-dev


# sets the specified directory as the working directory inside 
# the Docker image. 
# Any further commands run in the Dockerfile will be run in the 
# context of this directory.
WORKDIR /app


# We copy over the entire gems directory for our builder image, containing the already built artifact
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

# copy app files over
COPY . .

# tell docker the application will be listening on port 300 when the container is run
# (mostly for documentation purposes and doesn't actually open the port)
EXPOSE 3000

# main entry point to docker image 
# its the command thats run when container is created
CMD ["rails", "server", "-b", "0.0.0.0"]
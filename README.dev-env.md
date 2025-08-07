# Dev env

```sh

docker-compose -f docker-compose.dev-env.yml up -d --build

docker-compose -f docker-compose.dev-env.yml up -d

yarn --version

bundle install

yarn install

./bin/dev


bin/bundle exec rspec spec/features/filtering_services_spec.rb

```

## Test everything is still working

- [ ] is CSS/JS is building correctly
- [ ] does the page function still
- [ ] google maps API key shouldn't be required for build
- [ ]

```sh
bundle exec rails assets:precompile

rails assets:clobber

./bin/dev
```

### @rails/ujs Force alerts etc

## Completed

- [ ] Removed webpacker and moved to jsbundling-rails with rollup and babel
- [ ] Fixed google maps warning issue and added markers from scout
- [ ] Tested polyfills and js functionality still work and added wrappers around the code and fixed some small bugs that were throwing console errors around these changes, updated how files are imported too.
- [ ] moved css over to cssbundling-rails with postcss and sass support for the legacy sass
- [ ] Upgraded to latest PATCH version 6.0.3.6 > 6.0.6.1
- [ ] added temp fix for logger error in config/boot.rb and added to spec_helper

## TODO

- [ ] remove require "logger" from config/boot.rb spec/spec_helper.rb
- [ ] fix tests chrome stuff
-

## Tests

- devise
- shoulda

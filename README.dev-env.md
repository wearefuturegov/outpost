# Dev env

```sh

docker compose -f docker-compose.dev-env.yml up -d --build

docker compose -f docker-compose.dev-env.yml up -d

docker compose -f docker-compose.dev-env.yml exec outpost /bin/bash

yarn --version

bundle install

yarn install

./bin/dev


bin/bundle exec rspec spec/features/filtering_services_spec.rb



bin/rails check_public_index

sudo chown -R outpost-user:outpost-user /usr/local/bundle
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

- http://localhost:3000/api/v1/accessibilities

### @rails/ujs Force alerts etc

## Completed

- [ ] Removed webpacker and moved to jsbundling-rails with rollup and babel
- [ ] Fixed google maps warning issue and added markers from scout
- [ ] Tested polyfills and js functionality still work and added wrappers around the code and fixed some small bugs that were throwing console errors around these changes, updated how files are imported too.
- [ ] moved css over to cssbundling-rails with postcss and sass support for the legacy sass
- [ ] Upgraded to latest PATCH version 6.0.3.6 > 6.0.6.1
- [ ] added temp fix for logger error in config/boot.rb and added to spec_helper
- [ ] reinitialised the tests to debug for error and got the tests working
- [ ] upgraded from 6.0.6.1 > 6.1.7.10
- [ ] added new tests for the API routes for the tell us about app etc
- [ ] 6.1.7.10 > 7.0.8.7
- [ ] ruby 3.0.3 > 3.1.7

## TODO

- [ ] remove require "logger" from config/boot.rb spec/spec_helper.rb
- [ ] one test is suddenly failing!
- [ ] fix tests chrome stuff
- [ ] https://github.com/jhawthorn/discard is deprecated in rails
      Post-install message from devise:

[DEVISE] Please review the [changelog] and [upgrade guide] for more info on Hotwire / Turbo integration.

[changelog] https://github.com/heartcombo/devise/blob/main/CHANGELOG.md
[upgrade guide] https://github.com/heartcombo/devise/wiki/How-To:-Upgrade-to-Devise-4.9.0-%5BHotwire-Turbo-integration%5D
Post-install message from doorkeeper:
Starting from 5.5.0 RC1 Doorkeeper requires client authentication for Resource Owner Password Grant
as stated in the OAuth RFC. You have to create a new OAuth client (Doorkeeper::Application) if you didn't
have it before and use client credentials in HTTP Basic auth if you previously used this grant flow without
client authentication.

To opt out of this you could set the "skip_client_authentication_for_password_grant" configuration option
to "true", but note that this is in violation of the OAuth spec and represents a security risk.

Read https://github.com/doorkeeper-gem/doorkeeper/issues/561#issuecomment-612857163 for more details.
Post-install message from httparty:
When you HTTParty, you must party hard!

[DEVISE] Please review the [changelog] and [upgrade guide] for more info on Hotwire / Turbo integration.

[changelog] https://github.com/heartcombo/devise/blob/main/CHANGELOG.md
[upgrade guide] https://github.com/heartcombo/devise/wiki/How-To:-Upgrade-to-Devise-4.9.0-%5BHotwire-Turbo-integration%5D
Post-install message from doorkeeper:
Starting from 5.5.0 RC1 Doorkeeper requires client authentication for Resource Owner Password Grant
as stated in the OAuth RFC. You have to create a new OAuth client (Doorkeeper::Application) if you didn't
have it before and use client credentials in HTTP Basic auth if you previously used this grant flow without
client authentication.

To opt out of this you could set the "skip_client_authentication_for_password_grant" configuration option
to "true", but note that this is in violation of the OAuth spec and represents a security risk.

Read https://github.com/doorkeeper-gem/doorkeeper/issues/561#issuecomment-612857163 for more details.
Post-install message from httparty:
When you HTTParty, you must party hard!
Post-install message from rubyzip:
RubyZip 3.0 is coming!

---

The public API of some Rubyzip classes has been modernized to use named
parameters for optional arguments. Please check your usage of the
following classes:

- `Zip::File`
- `Zip::Entry`
- `Zip::InputStream`
- `Zip::OutputStream`

Please ensure that your Gemfiles and .gemspecs are suitably restrictive
to avoid an unexpected breakage when 3.0 is released (e.g. ~> 2.3.0).
See https://github.com/rubyzip/rubyzip for details. The Changelog also
lists other enhancements and bugfixes that have been implemented since
version 2.3.0.
2 installed gems you directly depend on are looking for funding.
Run `bundle fund` for details
outpost-user@8e882b3a83ca:/app$

## Tests

- devise
- shoulda

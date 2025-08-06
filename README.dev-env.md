# Dev env

```sh

docker-compose -f docker-compose.dev-env.yml up -d --build

yarn --version

bundle install

yarn install

bin/bundle exec puma -C config/puma.rb

```

## Test everything is still working

### CSS/JS is building

```sh
bundle exec rails assets:precompile

rails assets:clobber
```

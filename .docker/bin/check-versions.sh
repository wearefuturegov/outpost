#!/bin/sh

echo "NODE Version: $(node --version) (should be: $(node -p "require('./package.json').engines.node"))"
echo "NPM Version: $(npm --version)"
echo "Yarn Version: $(yarn --version) (should be: $(node -p "require('./package.json').engines.yarn"))"
echo "Ruby Version: $(ruby --version) (should be: $(cat .ruby-version))"
echo "Bundler Version: $(bundler --version) (should be: $(awk '/BUNDLED WITH/{getline; print}' Gemfile.lock))"

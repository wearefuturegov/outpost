release: rails db:migrate
web: bundle exec puma -C config/puma.rb
rake: bundle exec rake
console: bin/rails console
migrate_web: rails db:migrate && bundle exec puma -C config/puma.rb
cleanup: rm tmp/pids/server.pid
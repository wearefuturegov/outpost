RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.url_allowlist = [ 
      %r{^postgresql://.*_development:.*_development@postgres:5432}, 
      %r{^postgresql://.*_test:.*_test@postgres:5432}, 
      %r{^postgresql://.*_development:.*_development@localhost:5432}, 
      %r{^postgresql://.*_test:.*_test@localhost:5432},
      %r{^postgresql://.*:.*@postgres:5432/outpost?},
      %r{^postgresql://.*:.*@localhost:5432},
      %r{^postgres://.*:.*@localhost:5432},
      %r{^.*outpost:.*@localhost:5432/outpost_test},
      %r{^.*outpost:.*@outpost-test-postgres:5432/outpost}
    ]
    DatabaseCleaner.clean_with :truncation, except: %w(ar_internal_metadata)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

#   config.around(:each) do |example|
#     DatabaseCleaner.cleaning do
#       example.run
#     end
#   end

end

# bin/bundle exec rake service:add_parent_taxonomies

namespace :service do
  desc 'Add parent taxonomies to each service'
  task add_parent_taxonomies: :environment do
    Service.find_each(batch_size: 1000) do |service|
      service.add_parent_taxonomies
    end
  end
end
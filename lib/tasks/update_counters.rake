namespace :update_counters do
  task :all => :environment  do

    # Turn off logging for this rake task, otherwise it just fills up our logs
    dev_null = Logger.new('/dev/null')
    Rails.logger = dev_null
    ActiveRecord::Base.logger = dev_null

    puts "Updating taxonomy counters"
    Taxonomy.find_each do |taxonomy|
      Taxonomy.reset_counters(taxonomy.id, :services)
    end

    puts "Updating service counters"
    Service.find_each do |service|
      Service.reset_counters(service.id, :notes)
    end

    puts "Updating organisation counters"
    Organisation.find_each do |organisation|
      Organisation.reset_counters(organisation.id, :services)
      Organisation.reset_counters(organisation.id, :users)
    end

  end
end

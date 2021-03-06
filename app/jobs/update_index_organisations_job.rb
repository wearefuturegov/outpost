class UpdateIndexOrganisationsJob < ApplicationJob
    queue_as :default
  
    def perform(organisation)
      client = Mongo::Client.new(ENV["DB_URI"] || 'mongodb://root:password@localhost:27017/outpost_development?authSource=admin', {
        retry_writes: false
    })
      collection = client.database[:indexed_services]
      query = collection.find({ "organisation.id": { "$eq": organisation.id } }, { id: 1 })
      services = Service.find(query.map { |d| d['id'] })
      services.each {|s| s.update_this_service_in_index }
      client.close
    end
  end
  
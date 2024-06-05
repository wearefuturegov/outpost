class UpdateIndexOrganisationsJob < ApplicationJob
    queue_as :default
  
    def perform(organisation)

      client = get_mongo_client
      return unless client
      collection = client.database[:indexed_services]
      query = collection.find({ "organisation.id": { "$eq": organisation.id } }, { id: 1 })
      services = Service.find(query.map { |d| d['id'] })
      services.each {|s| s.update_this_service_in_index }
      client.close
    end


    def get_mongo_client
      begin
          client = Mongo::Client.new(ENV["DB_URI"] || 'mongodb://localhost:27017/outpost_development?authSource=admin', {
              retry_writes: false,
              connect_timeout: 2,
          })
      rescue Mongo::Error::NoServerAvailable, Mongo::Error::SocketError => e
          puts "Failed to connect to MongoDB server: #{e.message}"
          nil
      end
    end


  end
  
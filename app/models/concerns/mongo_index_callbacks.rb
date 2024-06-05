module MongoIndexCallbacks

    extend ActiveSupport::Concern

    attr_accessor :skip_mongo_callbacks

    included do
        after_commit :update_index, if: -> { skip_mongo_callbacks != true }
    end

    def update_index
        # makes sure it doesn't enqueue the job if we can't connect to the client
        # client = get_mongo_client
        # return unless client
        # client.close
        # UpdateIndexServicesJob.perform_later(self)
    end

    def update_this_service_in_index
        if self.approved? && self.publicly_visible?
            client = get_mongo_client
            return unless client
            collection = client.database[:indexed_services]
            collection.find_one_and_update({id: self.id}, IndexedServicesSerializer.new(self).as_json, {upsert: true})
            client.close
        elsif self.approved && !self.publicly_visible?
            client = get_mongo_client
            return unless client
            collection = client.database[:indexed_services]
            collection.find_one_and_delete({id: self.id})
            client.close
        end
    end

    def get_mongo_client
        begin
            client = Mongo::Client.new(ENV["DB_URI"] || 'mongodb://localhost:27017/outpost_development?authSource=admin', {
                retry_writes: false
            })
        rescue Mongo::Error::NoServerAvailable, Mongo::Error::SocketError => e
            puts "Failed to connect to MongoDB server: #{e.message}"
            nil
        end
    end
end
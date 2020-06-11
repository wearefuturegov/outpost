module MongoIndexCallbacks

    extend ActiveSupport::Concern

    included do
        after_save :update_index
    end

    def update_index
        client = Mongo::Client.new(ENV["MONGODB_URI"] || 'mongodb://127.0.0.1:27017/outpost_development')
        collection = client.database[:indexed_services]
        if self.approved?
            collection.find_one_and_update({id: self.id}, self.as_json)
        else
            collection.find_one_and_update({id: self.id}, self.last_approved_snapshot.object)
        end
    end

end
class Taxonomy < ApplicationRecord

    has_closure_tree order: 'sort_order', 
        dependent: :destroy, 
        numeric_order: true

    has_many :service_taxonomies
    has_many :services, through: :service_taxonomies

    attr_accessor :skip_mongo_callbacks
    after_save :update_index, unless: :skip_mongo_callbacks
    
    validates_presence_of :name, uniqueness: true

    def slug
        name.parameterize
    end

    scope :categories, -> { where(parent_id: 1) }

    def update_index
        client = Mongo::Client.new(ENV["MONGODB_URI"] || 'mongodb://127.0.0.1:27017/outpost_development')
        collection = client.database[:indexed_services]
        query = collection.find({ "taxonomies.id": { "$eq": self.id } }, { id: 1 })
        services = Service.find(query.map { |d| d['id'] })
        services.each {|s| s.update_index }
    end
end

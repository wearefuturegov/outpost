class IndexedServiceAtLocation
    include Mongoid::Document

    field :name, type: String
    field :description, type: String

    field :street_address, type: String

    field :taxonomies, type: Array
end

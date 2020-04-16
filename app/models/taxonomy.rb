class Taxonomy < ApplicationRecord
    has_many :service_taxonomies
    has_many :services, through: :service_taxonomies

    has_many :children, class_name: "Taxonomy",
                            foreign_key: "parent_id"

    belongs_to :parent, class_name: "Taxonomy", optional: true

    def slug
        name.parameterize
    end
end

class Taxonomy < ApplicationRecord

    has_closure_tree order: 'sort_order', 
        dependent: :destroy, 
        numeric_order: true

    has_many :service_taxonomies, dependent: :destroy
    has_many :services, -> { distinct }, through: :service_taxonomies

    has_and_belongs_to_many :directories, -> { distinct }

    attr_accessor :skip_mongo_callbacks
    after_commit :update_index, if: -> { skip_mongo_callbacks == !true }
    
    validates_presence_of :name, uniqueness: true
    validates :name, length: { minimum: 2, maximum: 100 }

    scope :filter_by_directory, -> (directory) { joins(:directories).where(directories: { name: directory }) }
    
    def slug
        name.parameterize
    end

    def update_index
        UpdateIndexTaxonomiesJob.perform_later(self)
    end

    def self.options_for_select
        # order("LOWER(name)").map { |e| [e.name, e.id] }.unshift(["All taxonomies", ""])
        Taxonomy.arranged_as_flat_array.map { |name, id| [name.html_safe, id] }.unshift(["All taxonomies", ""])
    end

    def self.arranged_as_flat_array(taxonomies = nil, level = 0)
        taxonomies ||= Taxonomy.hash_tree
      
        taxonomies.map do |taxonomy, sub_taxonomies|
          [["#{"&nbsp;" * level}#{taxonomy.name}", taxonomy.id], *arranged_as_flat_array(sub_taxonomies, level + 1)]
        end.flatten(1)
      end
end

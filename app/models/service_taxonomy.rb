class ServiceTaxonomy < ApplicationRecord
    belongs_to :service
    belongs_to :taxonomy, counter_cache: :services_count
end
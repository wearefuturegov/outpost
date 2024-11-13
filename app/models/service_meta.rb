class ServiceMeta < ApplicationRecord
  belongs_to :service
  validates :label, presence: true
  validates_uniqueness_of :label, scope: :service_id
end

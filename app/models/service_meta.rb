class ServiceMeta < ApplicationRecord
  belongs_to :service
  validates :key, presence: true
  validates_uniqueness_of :key, scope: :service
end

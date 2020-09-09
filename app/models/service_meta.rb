class ServiceMeta < ApplicationRecord
  belongs_to :service
  validates_presence_of :key
end

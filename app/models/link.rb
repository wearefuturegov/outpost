class Link < ApplicationRecord
  belongs_to :service
  validates_presence_of :label, :url
  validates_uniqueness_of :label, scope: :service_id, message: 'must be unique'
end

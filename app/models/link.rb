class Link < ApplicationRecord
  belongs_to :service
  validates_presence_of :label, :url
end

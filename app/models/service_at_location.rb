class ServiceAtLocation < ApplicationRecord
  belongs_to :service
  belongs_to :location
end
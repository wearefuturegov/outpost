class UpdateIndexServicesJob < ApplicationJob
    queue_as :default
  
    def perform(service)
        service.update_index
    end
end
  
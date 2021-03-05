class UpdateIndexServicesJob < ApplicationJob
    queue_as :default
  
    def perform(service)
        service.update_this_service_in_index
    end
end
  
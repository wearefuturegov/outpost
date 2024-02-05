class API::V1::MeController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :doorkeeper_authorize!
    
    def show
        render json: User.find(doorkeeper_token.resource_owner_id)
            .as_json(include: {
                organisation: {
                  only: [:id, :name],
                  include: {
                    services: {
                      only: [:id, :name],
                      include: {
                        service_at_locations: {
                          only: [:id],
                          include: {
                            location: {
                              only: [:id, :name, :address_1, :city, :postal_code]
                            }
                          }
                        }
                      }
                    }
                  }
                }
              })
        
    
    end
end

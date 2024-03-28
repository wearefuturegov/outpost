class API::V1::SendNeedsController < ApplicationController
    skip_before_action :authenticate_user!
  
    def index
        render json: json_tree(SendNeed.all.order(:name)).to_json
    end

    private

    def json_tree(send_needs)
        send_needs.map do |sn|
            {
                id: sn.id,
                label: sn.name,
                slug: sn.slug
            }
        end
    end
end

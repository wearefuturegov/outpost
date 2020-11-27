class API::V1::SendNeedsController < ApplicationController
    skip_before_action :authenticate_user!
  
    def index
        render json: json_tree(SendNeed.all)
    end

    private

    def json_tree(needs)
        needs.map do |t|
            {
                id: t.id,
                label: t.name,
                slug: t.slug
            }
        end
    end
end
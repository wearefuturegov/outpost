class API::V1::AccessibilitiesController < ApplicationController
    skip_before_action :authenticate_user!
  
    def index
        render json: json_tree(Accessibility.all)
    end

    private

    def json_tree(accessibilities)
        accessibilities.map do |a|
            {
                id: a.id,
                label: a.name,
                slug: a.slug
            }
        end
    end
end
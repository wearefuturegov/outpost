class API::V1::AccessibilityController < ApplicationController
    skip_before_action :authenticate_user!
  
    def index
        render json: json_tree(Accessibility.all)
    end

    private

    def json_tree(accessibility)
        accessibility.map do |t|
            {
                id: t.id,
                label: t.name,
                slug: t.slug
            }
        end
    end
end
class API::V1::TaxonomiesController < ApplicationController
    skip_before_action :authenticate_user!
  
    def index
        render json: json_tree(Taxonomy.hash_tree)
    end

    private

    def json_tree(taxonomies)
        taxonomies.map do |t, children|
            {
                label: t.name,
                value: t.name.parameterize,
                level: t.depth,
                children: json_tree(children)
            }
        end
    end
end
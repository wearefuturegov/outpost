class API::V1::TaxonomiesController < ApplicationController
    skip_before_action :authenticate_user!
  
    def index
        if params["directory"] === 'bod'
            render json: json_tree(Taxonomy.filter_by_directory('Buckinghamshire Online Directory').hash_tree)
        elsif params["directory"] === 'bfis'
            render json: json_tree(Taxonomy.filter_by_directory('Family Information Service').hash_tree)
        else
            render json: json_tree(Taxonomy.hash_tree)
        end
    end

    private

    def json_tree(taxonomies)
        taxonomies.map do |t, children|
            {
                id: t.id,
                label: t.name,
                slug: t.slug,
                level: t.depth,
                children: json_tree(children)
            }
        end
    end
end
class API::V1::TaxonomiesController < ApplicationController
    skip_before_action :authenticate_user!

    def index
        directory = Directory.find_by(label: params[:directory])
        if params[:directory].present? && directory
            render json: json_tree(Taxonomy.filter_by_directory(directory.name).hash_tree).to_json
        else
            render json: json_tree(Taxonomy.hash_tree).to_json
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

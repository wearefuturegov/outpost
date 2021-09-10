class API::V1::TaxonomiesController < ApplicationController
    skip_before_action :authenticate_user!
  
    def index

        if params[:directory].present? && Directory.any?

            # scout sends through lowercase label 'bfis', 'bod' etc - look up the name in app config to send to the application
            value = Directory.where(label: params[:directory]).first.name
            results = Taxonomy.filter_by_directory(value)

            if results.count > 0
                render json: json_tree(results.hash_tree)
            else 
                render json: {}
            end

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
class API::V1::TaxonomiesController < ApplicationController
    skip_before_action :authenticate_user!
  
    def index

        if params[:directory].present? && APP_CONFIG['directories'].present?

            # scout sends through lowercase label 'bfis', 'bod' etc - look up the name in app config to send to the application
            @get_value_from_label = APP_CONFIG['directories'].find{|directory| directory["label"] === params[:directory]};
            @results = (!@get_value_from_label.nil?) ? Taxonomy.filter_by_directory(@get_value_from_label["value"]) : {};

            if !@get_value_from_label.nil? && @results.count > 0
                render json: json_tree(@results.hash_tree)
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
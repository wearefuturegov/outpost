class API::V1::TaxonomiesController < ApplicationController
    skip_before_action :authenticate_user!
  
    def index
        # scout sends through lowercase label 'bfis', 'bod' etc - look up the name in app config to send to the application
        @get_value_from_label = APP_CONFIG['directories'].find{|directory| directory["label"] === params[:directory]}["value"];
        
        if params[:directory].present? && APP_CONFIG['directories'].map{|d| d['label']}.include?(params[:directory])
            render json: json_tree(Taxonomy.filter_by_directory(@get_value_from_label).hash_tree)
        elsif params[:directory].present? 
            render json: {'yo': 'ho'}
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
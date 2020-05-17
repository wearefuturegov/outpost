class API::V1::TaxonomiesController < ApplicationController
    skip_before_action :authenticate_user!
  
    def index
        # @tree = Taxonomy.hash_tree
        # .....
    end
  
end
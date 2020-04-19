class Admin::TaxonomiesController < Admin::BaseController
    before_action :set_taxonomies, only: [:index, :create]
    before_action :set_taxonomy, only: [:show, :update]
    before_action :set_possible_parents, only: [:show, :update, :index, :create]

    def index
      @taxonomy = Taxonomy.new
    end

    def show
    end
  
    def update
      if @taxonomy.update(taxonomy_params)
        redirect_to admin_taxonomies_path
      else
        render "show"
      end
    end
  
    def create
      @taxonomy = Taxonomy.create(taxonomy_params)
      if @taxonomy.save
        redirect_to admin_taxonomies_path
      else
        render "index"
      end
    end
  
    private

    def set_taxonomies      
      @taxonomies = Taxonomy.where(parent_id: nil)
    end
  
    def set_taxonomy
      @taxonomy = Taxonomy.find(params[:id])
      @possible_parents = Taxonomy.where.not(id: params[:id])
    end

    def set_possible_parents
        @possible_parents = Taxonomy.all
        @possible_parents = @possible_parents.where.not(id: params[:id]) if params[:id]
    end
  
    def taxonomy_params
      params.require(:taxonomy).permit(
        :name,
        :parent_id
      )
    end
  
  end
class Admin::TaxonomiesController < Admin::BaseController
  before_action :user_admins_only  
  before_action :set_taxonomies, only: [:index, :create]
  before_action :set_taxonomy, only: [:show, :update, :destroy]
  before_action :set_possible_parents, only: [:show, :update, :index, :create]

  def index
    @taxonomy = Taxonomy.new
  end

  def show
  end

  def update
    if @taxonomy.update(taxonomy_params)
      redirect_to admin_taxonomy_path, notice: "Taxonomy has been updated."
    else
      render "show"
    end
  end

  def create
    @taxonomy = Taxonomy.create(taxonomy_params)
    if @taxonomy.save
      redirect_to admin_taxonomies_path, notice: "Taxonomy has been created."
    else
      render "index"
    end
  end

  def destroy
    @taxonomy.destroy
    redirect_to admin_taxonomies_path, notice: "Taxonomy has been deleted."
  end
  
  private

  def set_taxonomies
    if params["directory"] === 'bod'
      @taxonomies = Taxonomy.filter_by_directory('Buckinghamshire Online Directory').hash_tree
    elsif params["directory"] === 'bfis'
      @taxonomies = Taxonomy.filter_by_directory('Family Information Service').hash_tree
    else
      @taxonomies = Taxonomy.hash_tree
    end
  end

  def set_taxonomy
    @taxonomy = Taxonomy.find(params[:id])
  end

  def set_possible_parents
    @possible_parents = Taxonomy.all
    @possible_parents = @possible_parents.where.not(id: params[:id]) if params[:id]
  end

  def taxonomy_params
    params.require(:taxonomy).permit(
      :name,
      :parent_id,
      :sort_order
    )
  end

end

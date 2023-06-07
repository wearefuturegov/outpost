class Admin::TaxonomiesController < Admin::BaseController
  before_action :user_admins_only  
  before_action :count_taxonomies, only: [:index]
  before_action :set_taxonomies, only: [:index, :create]
  before_action :set_taxonomy, only: [:show, :update, :destroy]
  before_action :set_possible_parents, only: [:index, :show, :update, :create]
  before_action :set_directories, only: [:index, :show, :create]

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
      # We need the counts for the index page, so let's set them only if needed
      count_taxonomies
      render "index"
    end
  end

  def destroy
    @taxonomy.destroy
    redirect_to admin_taxonomies_path, notice: "Taxonomy has been deleted."
  end

  private

  def set_taxonomies
    if params[:directory].present? && Directory.where(name: params[:directory]).any?
      @taxonomies = Taxonomy.filter_by_directory(params[:directory]).hash_tree
    elsif params[:directory].present? 
      redirect_to admin_taxonomies_path, notice: "Directory doesn't exist."
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
      :sort_order,
      directory_ids: []
    )
  end

  def count_taxonomies
    @taxonomy_counts = {
      all: {
        all: Taxonomy.all.count
      }
    }

    Directory.find_each do |directory|
      @taxonomy_counts[directory.name] = {
        all: Taxonomy.filter_by_directory(directory.name).count
      }
    end
  end

  def set_directories
    @directories = Directory.all
  end
end

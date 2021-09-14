class API::V1::SuitabilitiesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
      render json: json_tree(Suitability.all)
  end

  private

  def json_tree(suitabilities)
    suitabilities.map do |s|
      {
        id: s.id,
        label: s.name,
        slug: s.slug
      }
    end
  end
end
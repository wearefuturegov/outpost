class AddExtraSocialLinksToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :linkedin_url, :string
    add_column :services, :instagram_url, :string
  end
end

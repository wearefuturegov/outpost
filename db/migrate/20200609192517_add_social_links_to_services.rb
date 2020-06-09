class AddSocialLinksToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :twitter_url, :string
    add_column :services, :facebook_url, :string
    add_column :services, :youtube_url, :string
  end
end

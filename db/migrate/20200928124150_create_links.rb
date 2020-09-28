class CreateLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :links do |t|
      t.string :label
      t.string :url
      t.references :service, null: false, foreign_key: true

      t.timestamps
    end

    remove_column :services, :twitter_url
    remove_column :services, :facebook_url
    remove_column :services, :youtube_url
    remove_column :services, :linkedin_url
    remove_column :services, :instagram_url
    remove_column :services, :referral_url

  end
end

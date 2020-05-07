class AddTimestampsToOfstedItems < ActiveRecord::Migration[6.0]
  def change
    add_column :ofsted_items, :created_at, :datetime, null: false
    add_column :ofsted_items, :updated_at, :datetime, null: false
  end
end

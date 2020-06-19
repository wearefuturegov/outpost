class AddOfstedItemIdToService < ActiveRecord::Migration[6.0]
  def change
    add_reference :services, :ofsted_item, null: true, foreign_key: true
  end
end

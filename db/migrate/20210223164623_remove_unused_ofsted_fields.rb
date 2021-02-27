class RemoveUnusedOfstedFields < ActiveRecord::Migration[6.0]
  def change
    remove_column :ofsted_items, :link_to_ofsted_report, :string
    remove_column :ofsted_items, :related_rpps, :string
    remove_column :ofsted_items, :prov_villagetown, :string
    remove_column :ofsted_items, :setting_villagetown, :string
    remove_column :ofsted_items, :location_ward, :string
    remove_column :ofsted_items, :location_planning, :string
    remove_column :ofsted_items, :prov_consent_withheld, :string
  end
end

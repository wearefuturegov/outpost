class ChangeOfstedNestedFieldsToJsonb < ActiveRecord::Migration[6.0]
  def change
    change_column :ofsted_items, :childcare_age, :jsonb, using: 'childcare_age::jsonb'
    change_column :ofsted_items, :inspection, :jsonb, using: 'inspection::jsonb'
    change_column :ofsted_items, :notice_history, :jsonb, using: 'notice_history::jsonb'
    change_column :ofsted_items, :welfare_notice_history, :jsonb, using: 'welfare_notice_history::jsonb'
  end
end

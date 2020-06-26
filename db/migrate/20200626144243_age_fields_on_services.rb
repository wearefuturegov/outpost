class AgeFieldsOnServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :min_age, :integer
    add_column :services, :max_age, :integer
  end
end

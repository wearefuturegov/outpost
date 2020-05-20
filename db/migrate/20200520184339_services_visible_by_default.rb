class ServicesVisibleByDefault < ActiveRecord::Migration[6.0]
  def change
    change_column :services, :visible, :boolean, default: true
  end
end

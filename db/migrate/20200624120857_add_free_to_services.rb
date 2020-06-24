class AddFreeToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :free, :boolean
  end
end

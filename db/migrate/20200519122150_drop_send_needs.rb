class DropSendNeeds < ActiveRecord::Migration[6.0]
  def change
    drop_table :send_needs
    drop_table :send_needs_services
  end
end

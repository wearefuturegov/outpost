class DeviseAddLastseenableUser < ActiveRecord::Migration[6.0]
  def self.up
    add_column :users, :last_seen, :datetime
  end
  
  def self.down
    remove_column :users, :last_seen
  end
end
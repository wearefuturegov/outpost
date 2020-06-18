class ChangeBccnMembershipVarcharToBoolean < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :bccn_member, :boolean, :default => false
    remove_column :services, :bccn_membership_number
  end
end

class AddReferralCheckboxToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :needs_referral, :boolean
  end
end

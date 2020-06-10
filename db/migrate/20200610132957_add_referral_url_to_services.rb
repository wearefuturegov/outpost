class AddReferralUrlToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :referral_url, :string
  end
end

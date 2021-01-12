class AddAgeBandsToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :age_band_under_2, :boolean
    add_column :services, :age_band_2, :boolean
    add_column :services, :age_band_3_4, :boolean
    add_column :services, :age_band_5_7, :boolean
    add_column :services, :age_band_8_plus, :boolean
    add_column :services, :age_band_all, :boolean
  end
end

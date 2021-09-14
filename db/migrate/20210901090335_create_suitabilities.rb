class CreateSuitabilities < ActiveRecord::Migration[6.0]
  def change
    create_table :suitabilities do |t|
      t.string :name

      t.timestamps
    end

    create_join_table(:services, :suitabilities)
  end
end

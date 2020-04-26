class CreateSendNeeds < ActiveRecord::Migration[6.0]
  def change
    create_table :send_needs do |t|
      t.string :name

      t.timestamps
    end

    create_join_table(:services, :send_needs)
  end
end

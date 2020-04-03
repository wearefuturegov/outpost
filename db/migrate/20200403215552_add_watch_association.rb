class AddWatchAssociation < ActiveRecord::Migration[6.0]
  def change

    create_table :watches do |t|
      t.belongs_to :user
      t.belongs_to :service
      t.timestamps
    end

  end
end

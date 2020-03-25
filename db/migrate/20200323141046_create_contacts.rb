class CreateContacts < ActiveRecord::Migration[6.0]
  def change
    create_table :contacts do |t|
      t.belongs_to :service
      t.string :name
      t.string :title
    end
  end
end

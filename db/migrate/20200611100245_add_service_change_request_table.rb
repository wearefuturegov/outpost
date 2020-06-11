class AddServiceChangeRequestTable < ActiveRecord::Migration[6.0]
  def change
    create_table 'service_change_request' do |t|
      t.references :service, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.json :object, null: false
      t.timestamps
    end
  end
end

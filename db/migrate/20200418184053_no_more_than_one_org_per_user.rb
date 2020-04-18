class NoMoreThanOneOrgPerUser < ActiveRecord::Migration[6.0]
  def change

    drop_table :organisations_users

    add_reference :users, :organisation, index: true

  end
end

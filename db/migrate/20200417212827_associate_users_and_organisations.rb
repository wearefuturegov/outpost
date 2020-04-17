class AssociateUsersAndOrganisations < ActiveRecord::Migration[6.0]
  def change

    create_table :organisations_users, id: false do |t|
      t.belongs_to :user
      t.belongs_to :organisation
    end

  end
end

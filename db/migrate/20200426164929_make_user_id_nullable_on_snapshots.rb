class MakeUserIdNullableOnSnapshots < ActiveRecord::Migration[6.0]
  def change
    change_column :snapshots, :user_id, :integer, null: true
  end
end

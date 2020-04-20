class RemoveApprovalTables < ActiveRecord::Migration[6.0]
  def change
    drop_table :approval_items
    drop_table :approval_comments
    drop_table :approval_requests
  end
end

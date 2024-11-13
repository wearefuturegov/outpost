class AddServiceMetaLabel < ActiveRecord::Migration[6.0]
  def change
     # Add new label column
     add_column :service_meta, :label, :string

     # Copy data from key to label (only on up migration)
     reversible do |dir|
       dir.up do
         ServiceMeta.reset_column_information
         ServiceMeta.update_all('label = key')
       end
     end
  end
end

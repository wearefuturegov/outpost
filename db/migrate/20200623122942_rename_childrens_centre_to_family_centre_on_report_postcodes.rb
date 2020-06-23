class RenameChildrensCentreToFamilyCentreOnReportPostcodes < ActiveRecord::Migration[6.0]
  def change
    rename_column :report_postcodes, :childrens_centre, :family_centre
  end
end

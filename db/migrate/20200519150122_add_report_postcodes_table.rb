class AddReportPostcodesTable < ActiveRecord::Migration[6.0]
  def change

    create_table "report_postcodes", force: :cascade do |t|
      t.string "postcode"
      t.string "ward"
      t.string "childrens_centre"
    end

  end
end

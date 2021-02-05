namespace :report_postcodes do
  task :import => [ :environment ] do
    csv_file = File.open('lib/seeds/report_postcodes.csv', "r:utf-8")
    report_postcodes_csv = CSV.parse(csv_file, headers: true)

    report_postcodes_csv.each.with_index do |row, line|
      ReportPostcode.create(postcode: row["postcode"], ward: row["ward"], family_centre: row["childrens_centre"])
    end
  end
end
namespace :planning_area_postcodes do
  task :import => [ :environment ] do
    csv_file = File.open('lib/seeds/planning_area_postcodes.csv', "r:utf-8")
    planning_area_postcodes_csv = CSV.parse(csv_file, headers: true)

    planning_area_postcodes_csv.each.with_index do |row, line|
      PlanningAreaPostcode.create(postcode: row["Postcode"], primary_planning_area: row["Planning_Area"])
    end
  end
end
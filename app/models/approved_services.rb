class ApprovedServices

  def self.all
    ActiveRecord::Base.connection.exec_query(base_query)
  end

  private
  def self.base_query
    "
    with service_entries as (
    select *, row_number() over (partition by object#>> '{id}' order by object#>> '{created_at}') as row_number from (
    select object::jsonb from snapshots
    union all
    select service::jsonb || taxonomy::jsonb || location::jsonb as object from (
    select row_to_json(c) as service,
           json_build_object('taxonomies', json_agg(row_to_json(st))) as taxonomy,
           json_build_object('locations', json_agg(row_to_json(l))) as location from services c
        inner join service_taxonomies st on c.id = st.service_id
        inner join service_at_locations sl on c.id = sl.service_id
        inner join locations l on sl.location_id = l.id
        group by c.id) as json_columns) object
    where object->>'approved' = 'true')
    select object from service_entries where row_number = 1;
    "
  end
end

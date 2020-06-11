class ApprovedServices

  def self.all
    ActiveRecord::Base.connection.exec_query(base_query)
  end

  private
  def self.base_query
    "
    -- create a subquery 'service_entries' from a services/snapshots union
    with service_entries as (select *, row_number() over
         (partition by object#>> '{id}'
          order by object#>> '{created_at}') -- order by the created_at field
          as row_number -- select the row number in each grouping, as we need the most recent
    from (
    select object::jsonb from snapshots -- take the object field from snapshots
    -- combine with
    union all

    -- merge these three objects
    select service::jsonb || taxonomy::jsonb || location::jsonb as object from (

        -- convert the service to a JSON object
        select row_to_json(c) as service,

        -- aggregate the taxonomy and locations joins, and turn them into an object holding the array
        -- e.g. row 1, taxonomy 1, row 1 taxonomy 2
        -- becomes { 'taxonomies', [{...taxonomy 1}, {... taxonomy 2}]
        json_build_object('taxonomies', json_agg(row_to_json(st))) as taxonomy,
        json_build_object('locations', json_agg(row_to_json(l))) as location from services c

        inner join service_taxonomies st on c.id = st.service_id
        inner join service_at_locations sl on c.id = sl.service_id
        inner join locations l on sl.location_id = l.id
        group by c.id) as json_columns) object
    where object->>'approved' = 'true')

    -- select the most recent JSON object (most recent created_at)
    select object from service_entries where row_number = 1;
    "
  end
end


class ServiceAtLocationSerializer < ActiveModel::Serializer
    attribute :id
    attribute :service_id
    attribute :location_id
    belongs_to :location, serializer: LocationSerializer
    has_many :regular_schedules, serializer: RegularScheduleSerializer, key: :regular_schedule
    # @TODO add holiday_schedule here (holidayScheduleCollection)
end
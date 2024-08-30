class ServiceAtLocation < ApplicationRecord
  belongs_to :service
  belongs_to :location

  has_one :organisation, through: :service
  paginates_per 20

  has_many :contacts, through: :service
  has_many :taxonomies, through: :service
  has_many :regular_schedules, dependent: :destroy

  # before_destroy :destroy_associated_regular_schedules

  private

  # def destroy_associated_regular_schedules
  #   puts 'destroy_associated_regular_schedules'
  #   puts regular_schedules.inspect
  #   puts self.inspect
  #   puts id
  #   puts self.id
  #   associated_rgular_schedules = RegularSchedule.find_by(service_at_location_id: self.id)
  #   puts associated_rgular_schedules.inspect
  #   puts "\n\n\n\n"
  #   # .destroy_all
  # end

end
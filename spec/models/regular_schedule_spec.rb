require 'rails_helper'

RSpec.describe RegularSchedule, type: :model do
  it { should validate_presence_of :weekday }
  it { should validate_presence_of :opens_at }
  it { should validate_presence_of :closes_at }
end

require 'rails_helper'

RSpec.describe LocalOffer, type: :model do
  it { should validate_presence_of :description }
end

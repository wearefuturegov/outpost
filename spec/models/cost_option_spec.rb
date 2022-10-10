require 'rails_helper'

RSpec.describe CostOption, type: :model do
  it { should validate_presence_of :amount }
end

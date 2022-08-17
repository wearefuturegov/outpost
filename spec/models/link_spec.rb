require 'rails_helper'

RSpec.describe Link, type: :model do
  it { should validate_presence_of :label }
  it { should validate_presence_of :url }
end

require 'rails_helper'

RSpec.describe Directory, type: :model do
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
  it { should validate_presence_of :label }
  it { should validate_uniqueness_of :label }
end

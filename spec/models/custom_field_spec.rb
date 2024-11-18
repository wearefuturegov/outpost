require 'rails_helper'

RSpec.describe CustomField, type: :model do
  subject { FactoryBot.build :custom_field }

  it { should validate_presence_of :label }
  it { should validate_uniqueness_of :label }
  it { should validate_presence_of :field_type }
end

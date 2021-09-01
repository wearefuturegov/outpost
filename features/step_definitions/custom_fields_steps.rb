When 'there is an existing custom field section' do
  @custom_field_section = FactoryBot.create :custom_field_section
end

When 'I go to edit the custom field section' do
  click_link 'Services'
  click_link 'Custom fields'
  click_link @custom_field_section.name
end

When 'I add a new custom field' do
  click_link 'Add a field'
end

Then 'I can fill in the field for label with {string}' do |label|
  fill_in('Label', with: label)
end

Then 'I can select the custom field type as {string}' do |type|
  select type, from: 'Field type'
end

Then 'I save my changes' do
  click_link_or_button 'Update'
end

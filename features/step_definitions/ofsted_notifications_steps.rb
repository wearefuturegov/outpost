And('I navigate to the ofsted feed') do
  visit '/admin/ofsted/pending'
end

Then('I should see the updated ofsted item in the list') do
  expect_panel_with_status('Dummy Provider Setting...', 'Changed')
end

Then('I should see the added ofsted item in the list') do
  expect_panel_with_status('New Provider Setting Name', 'New provider')
end

Then('I should see the removed ofsted item in the list') do
  expect_panel_with_status('Dummy Provider Setting...', 'No longer in Ofsted feed')
end

def expect_panel_with_status(name, status)
  pending_panels = page.all('.todo-list__item')
  pending_panel = pending_panels.find {|p| p.has_css?('div h2', text: name)}
  expect(pending_panel).not_to be nil

  status_field = pending_panel.find('.todo-status strong')
  expect(status_field.text).to eq status
end
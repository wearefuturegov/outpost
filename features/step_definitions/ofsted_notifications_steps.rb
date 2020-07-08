And('I navigate to the ofsted feed') do
  visit '/admin/ofsted/pending'
end

Then('I should see the updated ofsted item in the list') do
  pending_panels = page.all('.pending-panel')
  pending_panel = pending_panels.find {|p| p.has_css?('div h2', text: 'Dummy Provider Setting...')}
  expect(pending_panel).not_to be nil

  status_field = pending_panel.find('.pending-status strong')
  expect(status_field.text).to eq 'Changed'
end

Then('I should see the added ofsted item in the list') do
  pending_panels = page.all('.pending-panel')
  pending_panel = pending_panels.find {|p| p.has_css?('div h2', text: 'New Provider Setting Name')}
  expect(pending_panel).not_to be nil

  status_field = pending_panel.find('.pending-status strong')
  expect(status_field.text).to eq 'New provider'
end

Then('I should see the removed ofsted item in the list') do
  pending_panels = page.all('.pending-panel')
  pending_panel = pending_panels.find {|p| p.has_css?('div h2', text: 'New Provider Setting Name')}
  expect(pending_panel).not_to be nil

  status_field = pending_panel.find('.pending-status strong')
  expect(status_field.text).to eq 'New provider'
end
module FillInHelper
  def click_fill_in(element, text)
    email_input = find(element)
    email_input.click
    email_input.send_keys(text)
  end
end

World(FillInHelper)
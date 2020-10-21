module OfstedItemsHelper

  def string_as_formatted_date_if_date possible_date_string
    begin
      date = possible_date_string.to_date
      return date.strftime('%d/%m/%Y')
    rescue ArgumentError
      return possible_date_string
    end
  end

end
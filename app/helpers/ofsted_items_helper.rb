module OfstedItemsHelper

  def format_if_date date_string
    begin
      date = date_string&.to_date
      return date&.strftime('%d/%m/%Y')
    rescue ArgumentError
      return date_string
    end
  end

end
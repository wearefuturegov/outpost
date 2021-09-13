module ServicesHelper

  def mark_unapproved_field(attribute)
    if @service.unapproved_changes?(attribute) && current_user.admin?
      "field--changed"
    end
  end

  def mark_unapproved_local_offer
    if @service.unapproved_changes?("local_offer") && current_user.admin?
      content_tag(:div, class: "changed") do
        yield
      end
    else
      content_tag(:div) do
        yield
      end
    end
  end

  def mark_unapproved_array(attribute)
    if @service.unapproved_changes?(attribute) && current_user.admin?
      content_tag(:div, class: "changed") do
        yield
      end
    else
      content_tag(:div) do
        yield
      end
    end
  end

  def valid_directory_list
    Directory.all.map{|dir| [dir.name, dir.id]}
  end
end
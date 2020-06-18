module ServicesHelper

  def service_creation_steps
    ['Basic Information', 'Access', 'Categorisation', 'Further Info', 'Confirmation']
  end

  def next_stage(stage)
    stages = service_creation_steps
    stages[stages.index(stage) + 1]
  end

  def prev_stage(stage)
    stages = service_creation_steps
    stages[stages.index(stage) - 1]
  end

  def mark_unapproved_field(attribute, child_attribute = false)
    if @service.unapproved_changes?(attribute, child_attribute = false)
      "field--changed"
    end
  end

  def mark_unapproved_local_offer
    if @service.unapproved_changes?("local_offer")
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
    if @service.unapproved_changes_array?(attribute)
      content_tag(:div, class: "changed") do
        yield
      end
    else
      content_tag(:div) do
        yield
      end
    end
  end

end
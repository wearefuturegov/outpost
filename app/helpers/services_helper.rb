module ServicesHelper

    def mark_unapproved_field(attribute, child_attribute = false)
        if @service.unapproved_changes?(attribute, child_attribute = false)
            "field--changed"
        end
    end

    def mark_unapproved_section(attribute)
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
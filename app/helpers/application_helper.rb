module ApplicationHelper

    def short_url(url)
        url
          .delete_prefix("https://")
          .delete_prefix("http://")
          .delete_prefix("www.")
          .delete_suffix("/")
          .truncate(25)
    end

    def diff(one, two)
        Diffy::Diff.new(one, two).to_s(:html).html_safe
    end

    def pretty_event(event)
        case event
        when "create"
            "Record created"
        when "update"
            "Updated"
        when "destroy"
            "Deleted"        
        when "restore"
            "Restored"
        when "archive"
            "Archived"
        when "import"
            "Record imported"
        when "approve"
            "Approved"
        end
    end

    def stepper_class(event)
        case event
        when "create"
            "stepper__step--solid"   
        when "archive"
            "stepper__step--cross"
        when "restore"
            "stepper__step--solid"
        when "import"
            "stepper__step--solid"
        when "approve"
            "stepper__step--tick"
        end
    end

end

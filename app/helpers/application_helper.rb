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
            "record created"
        when "update"
            "updated"
        when "destroy"
            "deleted"        
        when "restore"
            "restored"
        when "archive"
            "archived"
        when "import"
            "record imported"
        when "approve"
            "approved"
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

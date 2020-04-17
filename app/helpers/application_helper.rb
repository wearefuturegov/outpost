module ApplicationHelper

    def short_url(url)
        url
          .delete_prefix("https://")
          .delete_prefix("http://")
          .delete_prefix("www.")
          .delete_suffix("/")
          .truncate(25)
    end

    def pretty_event(event)
        case event
        when "create"
            "Created"
        when "update"
            "Updated"
        when "destroy"
            "Destroyed"
        when "import"
            "Imported"
        end
    end

end

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
            "Record created"
        when "update"
            "Updated"
        when "destroy"
            "Destroyed"
        when "import"
            "Record imported"
        end
    end

    def diff(one, two)
        Diffy::Diff.new(one, two).to_s(:html).html_safe
    end
end

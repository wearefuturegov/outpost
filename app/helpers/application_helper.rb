module ApplicationHelper

    def short_url(url)
        url
          .delete_prefix("https://")
          .delete_prefix("http://")
          .delete_prefix("www.")
          .delete_suffix("/")
          .truncate(25)
      end

end

module UsersHelper

    def last_seen_helper(value)
        if value    
            [time_ago_in_words(value).humanize, "ago"].join(" ")
        else
            "Never"
        end
    end

end
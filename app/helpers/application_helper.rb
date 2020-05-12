require 'differ/string'

module ApplicationHelper

    def map(lat, long)
        "<div class='map-holder' data-map='true' data-lat=#{lat} data-long=#{long}></div>".html_safe
    end

    def static_map(lat, long)
        image_tag "https://maps.googleapis.com/maps/api/staticmap?key=#{ENV['GOOGLE_CLIENT_KEY']}&size=550x350&markers=#{lat},#{long}", alt: ""
    end

    def short_url(url)
        url
          .delete_prefix("https://")
          .delete_prefix("http://")
          .delete_prefix("www.")
          .delete_suffix("/")
          .truncate(25)
    end

    def inline_differ(one, two)
        if one && two
            $; = ' '
            (one - two).format_as(:html).html_safe
        end
    end

    def differ(one, two)
        if one && two
            Differ.diff_by_word(one, two).format_as(:html).html_safe
        end
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
            "restored from a previous version"
        when "archive"
            "archived"
        when "unarchive"
            "removed from archive"
        when "import"
            "record imported"
        when "approve"
            "approved"
        when "ofsted_update"
            "updated from Ofsted feed"
        when "ofsted_create"
            "created from Ofsted feed"
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

    def short_time_ago_in_words(val)
        time_ago_in_words(val).gsub("about ", "")
    end

    def last_seen_helper(value)
        if value    
            [time_ago_in_words(value).humanize, "ago"].join(" ")
        else
            "Never"
        end
    end

    def status_tag(status)
        if status === "pending"
            "<span class='tag tag--yellow'>Pending</span".html_safe
        elsif status === "archived"
            "<span class='tag tag--grey'>Archived</span".html_safe
        elsif status === "scheduled"
            "<span class='tag tag--grey'>Scheduled</span".html_safe
        elsif status === "expired"
            "<span class='tag tag--grey'>Expired</span".html_safe
        else
            "<span class='tag'>Active</span".html_safe
        end
    end

    def link_to_add_fields(name, f, association)
        new_object = f.object.send(association).klass.new
        id = new_object.object_id
        fields = f.fields_for(association, new_object, child_index: id) do |builder|
            render("admin/services/editors/location-fields", l: builder)
        end
        link_to name, '#', class: "button button--small button--add", data: {id: id, fields: fields.gsub("\n", ""), add: true}
    end

    def feedback_topics
        [
           {
                label: "Something is out of date",
                value: "out-of-date"
           },
           {
                label: "I have extra information to add",
                value: "missing-info"
           },
           {
               label: "Something else",
               value: "something-else"
           }
         ]
    end

    def pretty_topic(topic)
        if topic
            topic.gsub('-', ' ').capitalize
        else
            "—"
        end
    end
    
end

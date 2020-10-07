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

    def pretty_event(event)
        case event
        when "create"
            "Record created"
        when "update"
            "Updated"
        when "destroy"
            "Deleted"        
        when "archive"
            "Archived"
        when "unarchive"
            "Removed from archive"
        when "import"
            "Record imported"
        when "approve"
            "Approved"
        end
    end

    def stepper_class(event)
        case event
        when "ofsted_create"
            "stepper__step--solid"   
        when "create"
            "stepper__step--solid"   
        when "archive"
            "stepper__step--cross"
        when "import"
            "stepper__step--solid"
        when "approve"
            "stepper__step--tick"
        end
    end

    def short_time_ago_in_words(val)
        time_ago_in_words(val).gsub("about ", "")
    end

    def status_tag(status)
        if status === "marked for deletion"
            "<span class='tag tag--red'>Marked for deletion</span".html_safe
        elsif status === "pending"
            "<span class='tag tag--yellow'>Pending</span".html_safe
        elsif status === "archived"
            "<span class='tag tag--grey'>Archived</span".html_safe
        elsif status === "invisible"
            "<span class='tag tag--grey'>Invisible</span".html_safe
        elsif status === "scheduled"
            "<span class='tag tag--grey'>Scheduled</span".html_safe
        elsif status === "expired"
            "<span class='tag tag--grey'>Expired</span".html_safe
        else
            "<span class='tag'>Active</span".html_safe
        end
    end

    def link_to_add_fields(name, f, association, view)
        new_object = f.object.send(association).klass.new
        id = new_object.object_id
        fields = f.fields_for(association, new_object, child_index: id) do |builder|
            render(view, l: builder, c: builder, sched: builder)
        end
        link_to name, '#', class: "button button--secondary button--add", data: {id: id, fields: fields.gsub("\n", ""), add: true}
    end

    def link_to_add_contact_fields(name, f, association, view)
        new_object = f.object.send(association).klass.new
        id = new_object.object_id
        fields = f.fields_for(association, new_object, child_index: id) do |builder|
            render(view, l: builder, c: builder)
        end
        link_to name, '#', class: "button button--secondary button--add", data: {id: id, fields: fields.gsub("\n", ""), add: true}
    end  

    def local_offer_checkbox(f, view)
        new_object = LocalOffer.new
        id = new_object.object_id
        fields = f.fields_for(:local_offer, new_object) do |builder|
            render(view, l: builder)
        end
        check_box_tag "local_offer", "1", f.object.local_offer, class: "checkbox__input", data: {id: id, fields: fields.gsub("\n", ""), local_offer: true}
    end
end
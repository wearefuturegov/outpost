module ApplicationHelper

    def map(lat, long)
        "<div class='map-holder' data-map='true' data-lat=#{lat} data-long=#{long}></div>".html_safe
    end

    def static_map(lat, long)
        image_tag "https://maps.googleapis.com/maps/api/staticmap?key=#{ENV['GOOGLE_CLIENT_KEY']}&size=550x350&markers=#{lat},#{long}", alt: ""
    end

    def pretty_event(event)
        case event
        when "create"
            "Created"
        when "update"
            "Updated"
        when "destroy"
            "Deleted"        
        when "archive"
            "Archived"
        when "restore"
            "Restored"
        when "import"
            "Imported"
        when "approve"
            "Approved"
        else
            event.capitalize
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
        if status.downcase === "active"
            "<span class='tag'>Active</span".html_safe
        elsif status === "pending" || status === "proposed"
            "<span class='tag tag--yellow'>Pending</span".html_safe
        elsif status === "marked for deletion"
            "<span class='tag tag--red'>Marked for deletion</span".html_safe
        else
            "<span class='tag tag--grey'>#{status.capitalize}</span".html_safe
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

    def local_offer_checkbox(builder, view)
        new_object = LocalOffer.new
        id = new_object.object_id
        fields = builder.fields_for(:local_offer, new_object) do |l|
            render(view, s: builder, l: l)
        end
        check_box_tag "local_offer", "1", builder.object.local_offer, class: "checkbox__input", data: {id: id, fields: fields.gsub("\n", ""), local_offer: true}
    end

    def is_text_dark(bgColor)
        color = bgColor[0] === '#' ? bgColor[1...7] : bgColor
        r = Integer(color[0..1], 16) #hexToR
        g = Integer(color[2..3], 16) #hexToG
        b = Integer(color[4..5], 16) #hexToB
        uicolors = [r / 255, g / 255, b / 255];
    
        c = uicolors.map{ |col| col <= 0.03928 ? col / 12.92 : (col + 0.055) / 1.055**2.4 }
    
        l = (0.2126 * c[0]) + (0.7152 * c[1]) + (0.0722 * c[2]);
    
        (l > 0.179) ? true : false
      end
end
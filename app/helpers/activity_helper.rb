module ActivityHelper

    def ofsted_item_link(id)
        if item = OfstedItem.find_by(id: id)
            link_to item.display_name, admin_ofsted_path(item)
        else
            "Not found"
        end
    end


end
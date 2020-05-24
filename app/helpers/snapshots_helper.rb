module SnapshotsHelper

    def locations_list(locations)
        # byebug
        content_tag(:ul) do
            locations.each do |l|
                content_tag(:li) do 
                    "fuck"
                end
            end
        end
    end

end
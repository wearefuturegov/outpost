module SnapshotsHelper

    def ordered_hash(hash)
        hash.sort_by{|key, value| key}.to_h.map do |key, value|
            "#{key.humanize}: #{value}"
        end.join("\n")
    end

    def ordered(array)
        array.sort_by{ |o| o["id"]}.map do |element|
            if element.is_a?(Hash)
                ordered_hash(element)
            else
                element
            end
        end.join("\n\n")
    end

    def diff(left, right)
        Diffy::Diff.new(left, right, :allow_empty_diff => false).to_s(:html).html_safe
    end


    def changed_fields(service)
        # "test"
        Snapshot.where(service: service).where("object->>'approved' = 'false'").count
    end

end
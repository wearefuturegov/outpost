module SnapshotsHelper

    def ordered_hash(hash)
        if hash.is_a?(Hash)
            hash.sort_by{|key, value| key}.to_h.map do |key, value|
                "#{key.humanize}: #{value}"
            end.join("\n")
        else
            hash
        end
    end

    def ordered(array)
        array.sort_by{ |o| o["id"]}.map do |element|
            ordered_hash(element)
        end.join("\n\n")
    end

    def diff(left, right)
        Diffy::Diff.new(left, right, :allow_empty_diff => false).to_s(:html).html_safe
    end
    
end
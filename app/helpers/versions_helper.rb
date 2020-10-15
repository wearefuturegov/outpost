module VersionsHelper

    def diff(left, right)
        Diffy::Diff.new(pretty_data(left), pretty_data(right), :allow_empty_diff => false).to_s(:html).html_safe
    end

    def pretty_data(raw_data)
        # handle arrays
        if raw_data.is_a?(Array)

            if raw_data.first.class == String
                raw_data.sort.join("\n\n")
            else
                # HOW DO WE SORT THIS CONSISTENTLY
                raw_data.map do |el|
                    prettify_hash(el)
                end.join("\n\n")
            end

        # handle hashes
        elsif raw_data.is_a?(Hash)
            prettify_hash(raw_data)

        # handle integers, strings, booleans
        else
            raw_data.to_s
        end
    end

    def prettify_hash(hash)
        hash.except(
            # keys we can safely ignore from hashes
            "updated_at", 
            "created_at", 
            "id",
            "sort_order",
            "slug",
            "parent_id",
            "service_id",
            "locked",
            "services_count"
        )
            .sort_by{|key, value| key}
            .to_h
            .map do |key, value|
            # handle special case of second-order nesting of accessibilities
            if key === "accessibilities"
                "Accessibilities: #{value.map{|value| value["name"]}.join(", ")}"
            # handle everything else
            else
                "#{key.humanize}: #{value}"
            end
        end.join("\n")
    end

end
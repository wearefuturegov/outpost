module TaxonomiesHelper

    def tree_view(taxonomies)
        content_tag(:ul) do
            taxonomies.map do |t, children|
                "<li>#{link_to(t.name, admin_taxonomy_path(t))} (#{t.services.count})</li>" + tree_view(children)
            end.join.html_safe
        end
    end

end
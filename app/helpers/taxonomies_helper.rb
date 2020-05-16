module TaxonomiesHelper

    def tree_view(taxonomies)
        content_tag(:ul) do
            taxonomies.map do |parent, children|
                content_tag(:li, (link_to(parent.name, admin_taxonomy_path(parent)) +  tree_view(children)).html_safe)
            end.join.html_safe
        end
    end

end
module TaxonomiesHelper

    def taxonomy_class(t)
        "taxonomy-tree__item--depth-" + String(t.depth)
    end

    def tree_view(taxonomies)
        content_tag(:ul, class: "taxonomy-tree") do
            taxonomies.map do |t, children|
                "<li class='taxonomy-tree__item #{taxonomy_class(t)}'>#{link_to(t.name, admin_taxonomy_path(t))} <span class='taxonomy-tree__count'>(#{t.service_taxonomies.length})</span></li>" + tree_view(children)
            end.join.html_safe
        end
    end

end
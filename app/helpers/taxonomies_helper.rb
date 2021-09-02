module TaxonomiesHelper

    def tree_view(taxonomies)
        content_tag(:ul, class: "taxonomy-tree") do
            taxonomies.map do |t, children|

                if params[:directory].present?
                    "<li class='taxonomy-tree__item'>#{link_to(t.name, admin_taxonomy_path(t))} <span class='taxonomy-tree__count'>(#{t.services.in_directory(params[:directory]).size})</span></li>" + tree_view(children)
                else 
                    "<li class='taxonomy-tree__item'>#{link_to(t.name, admin_taxonomy_path(t))} <span class='taxonomy-tree__count'>(#{t.services.size})</span></li>" + tree_view(children)
                end 
            end.join.html_safe
        end
    end

    # Sort a list of taxonomies by first if the taxonomy or it's children are selected
    def sorted_by_selected(taxonomies, service)
        taxonomy_ids = service.taxonomies.to_a.map(&:id)
        taxonomies.sort do |a, b|
            a_selected = taxonomy_ids.include?(a.id)
            b_selected = taxonomy_ids.include?(b.id)
            if a_selected == b_selected
                a.name <=> b.name
            elsif a_selected
                -1
            else
                1
            end
        end
    end
end
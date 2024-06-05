# This tool is for superadmins only right now
# it is only very simply optimised for large number of services, 
# if you run into errors you should be able to just re-run the command with it only updating ones where data will be changing
class Admin::Tools::BulkAddTaxonomiesController < Admin::BaseController

  def show
    @errors = flash.now[:errors] || []
  end

  def update
    services_taxonomy_id = params[:taxonomy]
    taxonomy_ids = setup_taxonomy_ids(params[:taxonomy_ids], services_taxonomy_id)

    if services_taxonomy_id.present? && taxonomy_ids.length > 0
      
      updated_services = 0
      skipped_services = 0
      errors_count = 0
      errors = []

      Service.joins(:service_taxonomies).where(service_taxonomies: { taxonomy_id: services_taxonomy_id }).includes(:taxonomies, :versions, :organisation, :service_at_locations, :locations, :directories_services, :directories, :taggings).distinct.find_each(batch_size: 10) do |service|
        
        service_updated = false
        service_taxonomy_ids = service.taxonomies.map(&:id)

        # budget optimisation - skip if the service already has the taxonomies we're wanting to add to it
        if (taxonomy_ids - service_taxonomy_ids).empty?
          skipped_services += 1
          next
        end

        # force paper trail version to be saved
        service.updated_at = Time.now

        # dont notify watchers
        service.skip_notify_watchers = true

        # we found the parents above to save some time
        service.skip_add_parent_taxonomies = true

        # we don't want to update the mongo index we can do that later
        service.skip_mongo_callbacks = true

        # skip things that do extra database lookups
        service.skip_cost_option_validation = true

      
        begin
          service_updated = ActiveRecord::Base.transaction do
            
            update_service = PaperTrail.request(enabled: false) do
              service.update!(taxonomy_ids: (service_taxonomy_ids | taxonomy_ids))
            end

            if update_service

              # create a manual papertrail version (if update is successful)
              # the .to_json method in service does a lot of queries and we know we're only updating the taxonomies and updated_at date here
              last_version = service.versions.last.object
              current_changes = service.as_json(only: [:taxonomies, :updated_at], include: { taxonomies: { methods: :slug } })
              new_object = last_version.merge(current_changes)
              
              version = PaperTrail::Version.create(
                item_type: 'Service', 
                item_id: service.id, 
                event: 'update', 
                whodunnit: nil, 
                object: new_object,
                object_changes: service.saved_changes
              )
              version.persisted? if version
            else
              false
            end

          end
        rescue ActiveRecord::RecordInvalid => e
          puts "Caught RecordInvalid exception: #{e.message}"
          errors << { id: service.id, name: service.name, error: "RecordInvalid", messages: [e.message] }
          errors_count += 1
        rescue ActiveRecord::RecordNotFound => e
          puts "Caught RecordNotFound exception: #{e.message}"
          errors << { id: service.id, name: service.name, error: "RecordNotFound", messages: [e.message] }
          errors_count += 1
        end


        if service_updated
          updated_services += 1
        else
          if !errors.map { |e| e[:id] }.include?(service.id)
            errors << { id: service.id, name: service.name, error: 'Transaction failed', messages: ['Update transaction failed, please view logs for more information']}
            errors_count += 1
          end
        end


      end

      # sort by id in case of dupes
      errors.sort_by! { |error| error[:id] }


      puts errors.inspect
      if errors.any?        
        flash.now[:alert] = "#{updated_services} services have been updated. #{skipped_services} services were skipped. There were #{errors_count} errors."
        @errors = errors
        render :show
      else
        redirect_to admin_settings_tools_bulk_add_taxonomies_path, notice: "#{updated_services} services have been updated. #{skipped_services} services were skipped."
      end

    else
      redirect_to admin_settings_tools_bulk_add_taxonomies_path, alert: "Please select at least one taxonomy to add."
    end
  end

  private


  def setup_taxonomy_ids(tax_ids, services_taxonomy_id)
    # remove empty values
    taxonomy_ids = tax_ids.reject { |c| c.empty? }

    # remove current taxonomy from list 
    taxonomy_ids = taxonomy_ids.reject { |c| c == services_taxonomy_id }

    # ensure the taxonomy id's are integers
    taxonomy_ids = taxonomy_ids.map(&:to_i)

    # to speed things up we fetch the parents of the selected taxonomies here
    # that way we can safely skip the add_parent_taxonomies callback 
    parent_taxonomy_ids = []
    taxonomy_ids.each do |taxonomy_id|
      parents = Taxonomy.find(taxonomy_id).ancestors.pluck(:id)
      parent_taxonomy_ids.concat(parents)
    end

    taxonomy_ids = (taxonomy_ids + parent_taxonomy_ids).uniq
  end




end

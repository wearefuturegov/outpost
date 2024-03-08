class API::V1::ServicesController < ApplicationController
    skip_before_action :authenticate_user!
    before_action -> { doorkeeper_authorize! :admin }

    # /api/v1/services?format=full|mini?ids=1,2,3
    def index
        format = params[:format]
        ids = params[:ids]
        errors = 0

        # no format no data
        errors += 1 unless ['full', 'mini'].include?(format) 

        # if ids are present then we only want to return those services
        # we only allow max 20 services to be requested at a time
        if ids.present?
            ids = ids.split(',').map(&:to_i)
            errors += 1 if ids.count > 20
        end


        if errors > 0
            render json: { error: 'Bad request' }, status: :bad_request
        else
            services = Service.order("updated_at DESC")
            services = services.where(id: ids) if ids
            services = services.page(params[:page]).per(20)
            if format == 'full'
                # @TODO this will return be a paginated list of services but it needs tests to ensure its open referral compliance 
                # render json: json_tree(services, services.map { |s| IndexedServicesSerializer.new(s).as_json })
            elsif format == 'mini'
                render json: json_tree(services, services.map { |s| mini_services_json_tree(s) })
            end
        end

    end

    # /api/v1/services/:id
    def show
        format = params[:format]
        if ['full', 'mini'].include?(format)
            service = Service.find(params[:id])
            if format == 'full'
                # @TODO this will return be a paginated list of services but it needs tests to ensure its open referral compliance 
                # render json: IndexedServicesSerializer.new(service).as_json
            elsif format == 'mini'
                render json: mini_services_json_tree(service)
            end
        else
            render json: { error: 'Bad request' }, status: :bad_request
        end
    end

    private

    def json_tree(services, service_content)
        {
            number: services.page(params[:page]).current_page,
            size: services.page(params[:page]).limit_value,
            totalPages: services.page(params[:page]).total_pages,
            totalElements: services.total_count,
            first: services.page(params[:page]).first_page?,
            last: services.page(params[:page]).last_page?,
            content: service_content
        }
    end

    def mini_services_json_tree(s)
        {
            id: s.id,
            name: s.name,
            status: s.status
        }
    end

end

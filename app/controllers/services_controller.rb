class ServicesController < ApplicationController

    def new
        @service = Service.new
    end

end
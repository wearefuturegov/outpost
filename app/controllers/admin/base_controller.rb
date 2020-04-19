class Admin::BaseController < ApplicationController
    before_action :authenticate_user!
    # this needs to move out into the application controller
    before_action :set_paper_trail_whodunnit
end
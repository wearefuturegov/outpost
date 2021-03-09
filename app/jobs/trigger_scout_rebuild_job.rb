class TriggerScoutRebuildJob < ApplicationJob
    queue_as :default
  
    def perform()
        if ENV["SCOUT_BUILD_HOOK"]
            byebug
            HTTParty.post(ENV["SCOUT_BUILD_HOOK"])
        end
    end
end
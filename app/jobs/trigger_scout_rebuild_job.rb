class TriggerScoutRebuildJob < ApplicationJob
    queue_as :default
  
    def perform()
        if Directory.any 
            Directory.all.each do |directory|
                HTTParty.post(directory.scout_build_hook) if directory.scout_build_hook.present?
            end
        else if ENV["SCOUT_BUILD_HOOK"]
            HTTParty.post(ENV["SCOUT_BUILD_HOOK"])
        end
    end
end
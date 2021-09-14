class TriggerScoutRebuildJob < ApplicationJob
    queue_as :default
  
    def perform()
        Directory.all.each do |directory|
            HTTParty.post(directory.scout_build_hook) if directory.scout_build_hook.present?
        end
    end
end
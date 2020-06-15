task :process_permanent_deletions => :environment  do
    Service.discarded.each do |s|
        # TODO:
        # 1. check if marked_for_deletion value is more than 3o days in the past
        # 2. If so, delete service and all its snapshots and dependents
    end
end
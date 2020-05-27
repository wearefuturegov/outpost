module HasSnapshots

    extend ActiveSupport::Concern

    included do
        attr_accessor :snapshot_action
        after_save :capture_on_save
    end

    def capture_on_save
        if self.snapshot_action
            capture(self.snapshot_action)
        elsif self.id_previously_changed?
            capture("create")
        else
            capture("update")
        end
    end

    def capture(snapshot_action)
        new_snapshot = Snapshot.new(
            service: self,
            user: Current.user,
            action: snapshot_action,
            object: self.as_json(include: [
                :taxonomies, 
                :locations,
                :contacts,
                :cost_options,
                :local_offer,
                :regular_schedules
            ]),
            object_changes: self.saved_changes.as_json
        )
        new_snapshot.save
    end
end
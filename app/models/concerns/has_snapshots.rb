module HasSnapshots

    extend ActiveSupport::Concern

    included do
        attr_accessor :snapshot_action
        after_save :capture_on_save
    end

    def capture_on_save
        capture(self.snapshot_action || (self.id_previously_changed? ? "create" : "update"))
    end

    def capture(snapshot_action)
        new_snapshot = self.snapshots.new(
            user: Current.user,
            action: snapshot_action,
            object: self.as_json(include: [
                :taxonomies, 
                :send_needs,
                :locations
            ]),
            object_changes: self.saved_changes.as_json
        )
        new_snapshot.save
    end
end


# TODOS
# - Make sure all attributes are captured
# - Update UI everywhere
# - Goodbye to paper trail
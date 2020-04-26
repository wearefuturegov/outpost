module HasSnapshots
    extend ActiveSupport::Concern

    included do
        after_save :capture
    end

    def capture
        new_snapshot = self.snapshots.new(
            user: User.last, # TODO: use current user
            action: "update",
            object: self.as_json(include: [
                :taxonomies, 
                :send_needs
            ]),
            object_changes: self.saved_changes.as_json
        )
        byebug
        new_snapshot.save
    end
end


# TODOS
# 1. Attribute changes to current_user or default "System"
# 2. Handle other events:
#       - create
#       - approve
#       - archive
#       - unarchive
# 3. Make sure a snapshot is saved when an old snapshot is restored
# 4. Make sure all attributes are captured
# 5. Update UI everywhere
# 6. Goodbye to paper trail
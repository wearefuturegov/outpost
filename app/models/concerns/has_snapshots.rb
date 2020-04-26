module HasSnapshots
    extend ActiveSupport::Concern

    included do
        after_save :capture
    end

    def capture
        # byebug
        new_snapshot = self.snapshots.new(
            user: User.last, # TODO: use current user
            action: "update",
            object: self.as_json(include: [
                :service_taxonomies, 
                :send_needs
            ]),
            object_changes: self.saved_changes.as_json
        )
        new_snapshot.save
    end
end
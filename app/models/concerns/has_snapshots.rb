module HasSnapshots
    extend ActiveSupport::Concern

    included do

        after_save :capture
    end

    def capture
        # byebug
        e = self.snapshots.new(
          user: User.last,
          action: "update",
          object: self.as_json(include: :service_taxonomies),
          object_changes: self.saved_changes.as_json
        )
        e.save
    end
end
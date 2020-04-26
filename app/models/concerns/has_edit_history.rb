module HasEditHistory
    extend ActiveSupport::Concern

    included do
        after_save :record_edit
    end

    def record_edit
        e = self.edits.new(
          user: User.last,
          action: "update",
          object: self.as_json(include: :service_taxonomies)
        )
        e.save
    end
end
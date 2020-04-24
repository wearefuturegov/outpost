module HasEditHistory
    extend ActiveSupport::Concern

    included do
        after_save :record_edit
    end

    def record_edit
        e = self.edits.new(
          user: User.last,
          action: "update",
          object: self.to_json
        )
        byebug
        e.save
    end

end
class CustomFieldSection < ApplicationRecord
    validates_presence_of :name, uniqueness: true

    has_many :custom_fields, -> { order(created_at: :asc) }
    accepts_nested_attributes_for :custom_fields, allow_destroy: true, reject_if: :all_blank

    default_scope { order(sort_order: :asc) }
    
    scope :visible_to, -> (current_user){ current_user.admin ? all : where(public: true) }
end

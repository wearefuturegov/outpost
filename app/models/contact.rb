class Contact < ApplicationRecord
  belongs_to :service

  validate :validate_not_blank

  def validate_not_blank
    if name.blank? && email.blank? && phone.blank?
      errors.add(:base, :missing_contact_details)
    end
  end
end
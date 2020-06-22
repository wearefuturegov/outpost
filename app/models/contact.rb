class Contact < ApplicationRecord
  belongs_to :service

  validate :validate_not_blank

  def validate_not_blank
    if name.blank? && email.blank? && phone.blank?
      errors.add(:base, "Each contact needs either a name, email or phone number")
    end
  end

end
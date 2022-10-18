class FileUpload < ApplicationRecord
    has_one_attached :file

    validates :var, presence: true, uniqueness: true

end

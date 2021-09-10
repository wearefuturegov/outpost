class DirectoryTaxonomy < ApplicationRecord
  belongs_to :taxonomy
  belongs_to :directory
end
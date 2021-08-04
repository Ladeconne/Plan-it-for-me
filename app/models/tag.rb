class Tag < ApplicationRecord
  belongs_to :category, optional: true
end

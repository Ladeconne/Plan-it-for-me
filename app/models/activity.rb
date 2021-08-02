class Activity < ApplicationRecord
  belongs_to :trip
  belongs_to :day, optional: true
end

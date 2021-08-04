class Activity < ApplicationRecord
  belongs_to :trip
  belongs_to :day, optional: true

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  # validates :picture, :name, :description, :link, :address, presence: true
end

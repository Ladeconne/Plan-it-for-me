class Activity < ApplicationRecord
  belongs_to :trip, optional: true
  belongs_to :day, optional: true
  has_many :activity_categories
  has_many :categories, through: :activity_categories

  geocoded_by :address
  # after_validation :geocode, if: :will_save_change_to_address?

  # validates :picture_url, :name, :address, presence: true
end

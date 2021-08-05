class Activity < ApplicationRecord
  belongs_to :trip
  belongs_to :day, optional: true
  has_many :activity_categories, dependent: :destroy

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  validates :picture_url, :name, :description, :link, :address, presence: true
end

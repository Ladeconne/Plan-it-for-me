class Activity < ApplicationRecord
  belongs_to :trip
  belongs_to :day, optional: true
  validates :picture, :name, :description, :link, :address, presence: true
end

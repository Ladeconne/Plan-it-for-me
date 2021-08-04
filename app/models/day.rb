class Day < ApplicationRecord
  belongs_to :trip
  validates :date, presence: true
  # validate :date_future?, on: :create
end

class Trip < ApplicationRecord
  belongs_to :user
  validates :city, :start_date, :end_date, presence: true
  validate :date_future?, on: :create
end

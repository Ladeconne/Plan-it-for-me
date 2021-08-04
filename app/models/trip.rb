class Trip < ApplicationRecord
  belongs_to :user
  validates :city, :start_date, presence: true
  # validates :end_date, presence: true, date: { after_or_equal_to: :start_date }
  validate :date_future?, on: :create
  has_many :activities
end

class Day < ApplicationRecord
  attr_accessor :seed

  belongs_to :trip
  validates :date, presence: true
  validate :date_future?, on: :create

  private

  def date_future?
    return if seed
    return if !date.present?
    errors.add(:date, "can't be in the past") if date < Date.today
  end
end

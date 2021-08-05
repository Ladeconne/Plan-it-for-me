class Trip < ApplicationRecord
  attr_accessor :seed

  belongs_to :user
  has_many :activities

  validates :city, :start_date, presence: true
  validates :end_date, presence: true
  validate :end_after_start?, on: :create
  validate :date_future?, on: :create

private


  has_many :activities
  has_many :days

  def date_future?
    return if seed
    errors.add(:start_date, "can't be in the past") if start_date < Date.today

    errors.add(:end_date, "can't be in the past") if end_date < Date.today
  end

  def end_after_start?
    return if seed
    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end

end

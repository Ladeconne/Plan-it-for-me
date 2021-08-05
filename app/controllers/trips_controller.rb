class TripsController < ApplicationController
  before_action :set_trip, only: [:show, :destroy]
  def index
    @trips = Trip.where(user: current_user)
  end

  def show
    @activities = @trip.activities.geocoded
    @markers = @activities.map do |activity|
      {
        lat: activity.latitude,
        lng: activity.longitude,
        info_window: render_to_string(partial: "info_window", locals: { activity: activity })
      }
    end
  end

  def destroy
    @trip.destroy
    redirect_to trips_path
  end


  def your_trip
    fake_activities

    # current_user = User.find_by_id(session[:current_user_id])
    # activities that the user choosed
     @markers = @activities.map do |activity|
      {
        lat: activity.latitude,
        lng: activity.longitude,
        info_window: render_to_string(partial: "info_window", locals: { activity: activity })
      }
    end
    # Date the user choose
    # start_date = session[:start_date]
    # end_date = session[:end_date]
    @day_activities = []
    cloned = @activities.dup
    days = (Date.today..(Date.today + 4)).to_a
    sorted_activities = [cloned[0]]

    while cloned.length.positive?
      first_activity = cloned[0]
      rest_activities = cloned[1..-1]
      cloned.delete_at(0)

      if !cloned.empty?
        with_distance = rest_activities.map do |act|
          {
            activity: act,
            distance: first_activity.distance_to(act.to_coordinates)
          }
        end
        cloned = with_distance.sort { |a, b| a[:distance] <=> b[:distance] }.map { |t| t[:activity] }
      end

      sorted_activities << cloned[0] if cloned[0]
    end

    @result = []

    sorted_activities.each_slice(3).with_index do |slice, idx|
      day_activities = {
        day: days[idx],
        activities: slice
      }
      @result << day_activities
    end

    # city the user choose
    @city = ['Marseille', 'Paris', 'Lyon', 'Nice', 'Reims'].sample
  end

  def fake_activities
    @activities = []
    addresses = ['Rue de Rivoli, 75001 Paris', "1 Rue de la Légion d'Honneur, 75007 Paris", "Pl. du Trocadéro et du 11 Novembre, 75116 Paris", "Rue Antoine Bourdelle, 75015 Paris", 'Rue Chaptal, 75009 Paris', 'Rue Geoffroy-Saint-Hilaire, 75005 Paris']
    names = ['A Museum', 'B Museum', 'X park', 'X Sprt Ground', 'X Church', 'Z Sport']
    rand(4..6).times do
    # session[:activities].each do
    activity = Activity.new(
               picture_url: 'https://images.unsplash.com/photo-1508180588132-ec6ec3d73b3f?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80.png',
               name: names.pop,
               description: 'This is a beatiful place.',
               link: 'https://en.wikipedia.org/wiki/Rue_de_Rivoli',
               address: addresses.pop,
               favourite: false,
               trip: nil,
               day: nil)
    activity.geocode
    @activities << activity if activity.latitude
    end
  end

  private

  def set_trip
    @id = params[:id]
    @trip = Trip.find(@id)
  end
end

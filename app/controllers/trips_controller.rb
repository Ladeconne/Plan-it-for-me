class TripsController < ApplicationController
  before_action :set_trip, only: %i[show destroy]
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

  def create
    @start_date = session[:start_date]
    @end_date = session[:end_date]
    @city = session[:city]
    @trip = Trip.new(city: @city, start_date: @start_date, end_date: @end_date)
    @activity_ids = params[:search].keys # [2,4,6,8]
    @trip.user = current_user if user_signed_in?
    @trip.save
    session[:current_trip] = @trip.id
    Activity.where(id: @activity_ids).update_all(trip_id: @trip.id)
  end

  def your_trip
    if session[:current_trip]
      @trip = Trip.find(session[:current_trip])
    else
      create
    end
    @trip.days.destroy_all
    if params[:search].present?
      @trip.activities.update_all(trip_id: nil)
      params[:search].each_key do |id|
        Activity.find(id).update_columns(trip_id: @trip.id)
      end
    end
    @next = 0
    @prev = nil
    calculate_day_plan
  end

  def next
    @trip = Trip.find(session[:current_trip])
    calculate_day_plan
    @day = @result[params[:day].to_i - 1]
    @next = @result[params[:day].to_i] ? params[:day].to_i + 1 : nil
    @prev = @next ? @next - 1 : params[:day].to_i - 1
    @result = [@day]
    @date = @result[0][:day][:date]
    render 'your_trip'
  end

  def prev
    @trip = Trip.find(session[:current_trip])
    calculate_day_plan
    @day = @result[params[:day].to_i - 1]
    @next = @result[params[:day].to_i] ? params[:day].to_i + 1 : nil
    @prev = @next ? @next - 1 : params[:day].to_i - 1
    @result = [@day]
    @date = @result[0][:day][:date]
    render 'your_trip'

    # params[:day]
    # @trip = Trip.find(session[:current_trip])
    # calculate_day_plan
    # @day = @result[params[:day].to_i - 1]
    # if params[:day] == '1'
    #   @next = 1
    # else
    #   @result = [@day]
    #   @next = @result[params[:day].to_i]
    #   @date = @result[0][:day][:date]
    # end
    # render 'your_trip'
  end

  private

  def calculate_day_plan
    # current_user = User.find_by_id(session[:current_user_id])
    # activities that the user choosed
    @markers = @trip.activities.map do |activity|
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
    cloned = @trip.activities.geocoded.dup.to_a
    days = (@trip.start_date..@trip.end_date).to_a
    sorted_activities = [cloned[0]]
    @city = @trip.city

    days = days.map do |date|
      Day.find_or_create_by(trip: @trip, date: date)
    end

    while cloned.length.positive?
      first_activity = cloned[0]
      rest_activities = cloned[1..-1]
      cloned.delete_at(0)

      unless cloned.empty?
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

      day_activities[:activities].each do |act|
        act.update(day: day_activities[:day])
      end
      @result << day_activities
    end
    # city the user choose
    session[:trip_id] = @trip.id unless user_signed_in?
  end

  def set_trip
    @id = params[:id]
    @trip = Trip.find(@id)
  end
end

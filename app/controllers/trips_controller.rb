class TripsController < ApplicationController
  before_action :set_trip, only: %i[show destroy edit update]
  def index
    @trips = Trip.where(user: current_user)
  end

  def show
    @days = @trip.days.order(:date).distinct
    set_activities
    @next_day = @trip.days.order(:date).first
    @markers = @trip.activities.where.not(day_id: nil).map do |activity|
      {
        lat: activity.latitude,
        lng: activity.longitude,
        info_window: render_to_string(partial: "info_window", locals: { activity: activity })
      }
    end
  end

  def edit
    @day = @trip.days.order(:date).distinct
  end

  def update
    # connect the activity)id with the days[:date]

    @days = @trip.days
    @days.each do |day|
      activity_ids = params[day.id.to_s][:activities] # array
      activity_ids.each do |id|
        activity = Activity.find(id)
        activity.update(day_id: day.id)
      end
      # @trip.update(trip_params)
    end
    redirect_to trip_path(@trip)
  end

  def day
    @day = Day.find(params[:id])
    @trip = @day.trip
    set_activities
    @next_day = @trip.days.where('id > ?', @day.id).first
    @prev_day = @trip.days.where('id < ?', @day.id).last
    @markers = @trip.activities.geocoded.where.not(day_id: nil).map do |activity|
      {
        lat: activity.latitude,
        lng: activity.longitude,
        info_window: render_to_string(partial: "info_window", locals: { activity: activity })
      }
    end
    @days = [@day]
    render 'show'
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

    Activity.where(id: session[:activity_ids]).update_all(trip_id: @trip.id)
 acts = []

    @result.each do |t|
      acts << t[:activities] # [[act1, act2], [act4]]
    end

    @markers = acts.flatten.map do |activity|
      {
        lat: activity.latitude,
        lng: activity.longitude,
        info_window: render_to_string(partial: "info_window", locals: { activity: activity })
      }
    end

  end

  def next
    @trip = Trip.find(session[:current_trip])
    calculate_day_plan
    @day = @result[params[:day].to_i - 1]
    @next = @result[params[:day].to_i] ? params[:day].to_i + 1 : nil
    @prev = @next ? @next - 1 : params[:day].to_i - 1
    @result = [@day]
    if @result[0] && @result[0][:day]
      @date = @result[0][:day][:date]
    else
      @date
    end
    if params[:show].present?
      set_activities
      render 'show'
    else
      render 'your_trip'
    end
  end

  def prev
    @trip = Trip.find(session[:current_trip])
    calculate_day_plan
    @day = @result[params[:day].to_i - 1]
    @next = @result[params[:day].to_i] ? params[:day].to_i + 1 : nil
    @prev = @next ? @next - 1 : params[:day].to_i - 1
    @result = [@day]
    if @result[0] && @result[0][:day]
      @date = @result[0][:day][:date]
    else
      @date
    end
    if params[:show].present?
      set_activities
      render 'show'
    else
      render 'your_trip'
    end
  end

  private

  def calculate_day_plan
    # current_user = User.find_by_id(session[:current_user_id])
    # activities that the user choosed
    @markers = @trip.activities.where.not(day_id: nil).map do |activity|
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

    sorted_activities.each_slice(2).with_index do |slice, idx|
      day_activities = {
        day: days[idx],
        activities: slice
      }

      day_activities[:activities].each do |act|
        act.update(day: day_activities[:day]) unless act.day.present?
        session[:activity_ids].delete(act.id)
      end
      @result << day_activities
    end

    @result = @result.reject { |r| !r[:day] }

    # city the user choose
    session[:trip_id] = @trip.id unless user_signed_in?
  end

  def set_activities
    @activities = @trip.activities.geocoded
    @markers = @activities.map do |activity|
      {
        lat: activity.latitude,
        lng: activity.longitude,
        info_window: render_to_string(partial: "info_window", locals: { activity: activity })
      }
    end
  end

  def trip_params
    params.require(:trip).require(:activity_ids).permit(:activity_ids)
  end

  def set_trip
    @id = params[:id]
    @trip = Trip.find(@id)
  end
end

class TripsController < ApplicationController
  before_action :set_trip, only: %i[show destroy edit update]
  def index
    @trips = Trip.where(user: current_user)
  end

  def show
    @days = @trip.days.order(:date).distinct
    # set_activities
    @next_day = @trip.days.order(:date).first


    activities = @trip.days.map { |day| day.activities }.flatten

    ids = activities.map { |act| act.day_id }.uniq

    urls = ['https://res.cloudinary.com/dozqozwjs/image/upload/v1628747759/love_1_azo6v7.png', 'https://res.cloudinary.com/dozqozwjs/image/upload/v1628747763/love_2_lmpovo.png', 'https://res.cloudinary.com/dozqozwjs/image/upload/v1628747766/love_3_tfswx3.png']

    marker_images = {}

    ids.each_with_index do |id, index|
      marker_images[id] = urls[index]
    end



    @markers = activities.map do |activity|
      {
        lat: activity.latitude,
        lng: activity.longitude,
        info_window: render_to_string(partial: "info_window", locals: { activity: activity }),
        image_url: marker_images[activity.day_id]

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
    # set_activities
    @next_day = @trip.days.where('id > ?', @day.id).first
    @prev_day = @trip.days.where('id < ?', @day.id).last

    activities = @day.activities

    ids = activities.map { |act| act.day_id }.uniq

    urls = ['https://res.cloudinary.com/dozqozwjs/image/upload/v1628747759/love_1_azo6v7.png', 'https://res.cloudinary.com/dozqozwjs/image/upload/v1628747763/love_2_lmpovo.png', 'https://res.cloudinary.com/dozqozwjs/image/upload/v1628747766/love_3_tfswx3.png']

    marker_images = {}

    ids.each_with_index do |id, index|
      marker_images[id] = urls[index]
    end

    @markers = activities.map do |activity|
      {
        lat: activity.latitude,
        lng: activity.longitude,
        info_window: render_to_string(partial: "info_window", locals: { activity: activity }),
        image_url: marker_images[activity.day_id]
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






    if @trip.activities.any? { |act| act.day }
      # raise
      @city = @trip.city


       # {}

      @result = @trip.days.map do |day|
        {activities: Activity.where(day: day), day: day}
      end

      # @result = [{activities: @trip.activities.where.not(day_id: nil)}]
      # puts 9
      @next = 1
    else
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

    Activity.where(id: session[:activity_ids]).update_all(trip_id: @trip.id)

    acts = []
    @result.each do |t|
      acts << t[:activities] # [[act1, act2], [act4]]
    end


    ids = acts.flatten.map { |act| act.day_id }.uniq

    urls = ['https://res.cloudinary.com/dozqozwjs/image/upload/v1628747759/love_1_azo6v7.png', 'https://res.cloudinary.com/dozqozwjs/image/upload/v1628747763/love_2_lmpovo.png', 'https://res.cloudinary.com/dozqozwjs/image/upload/v1628747766/love_3_tfswx3.png']

    marker_images = {}

    ids.each_with_index do |id, index|
      marker_images[id] = urls[index]
    end


    @markers = acts.flatten.map do |activity|
      {
        lat: activity.latitude,
        lng: activity.longitude,
        info_window: render_to_string(partial: "info_window", locals: { activity: activity }),
        image_url: marker_images[activity.day_id]
      }
    end
    # binding.pry
  end

  def next
    @trip = Trip.find(session[:current_trip])
    # calculate_day_plan
    day =  @trip.days[params[:day].to_i - 1]
    @day = { day: @trip.days[params[:day].to_i - 1], activities: Activity.where(day: day) }



    # @next = @result[params[:day].to_i] ? params[:day].to_i + 1 : nil
    # @prev = @next ? @next - 1 : params[:day].to_i - 1

    @next = params[:day].to_i + 1 unless params[:day].to_i == @trip.days.length
    @prev = params[:day].to_i - 1 unless params[:day].to_i == 1

    @result = [@day]


     activities = @trip.activities.where.not(day_id: nil)

    ids = activities.map { |act| act.day_id }.uniq

    urls = ['https://res.cloudinary.com/dozqozwjs/image/upload/v1628747759/love_1_azo6v7.png', 'https://res.cloudinary.com/dozqozwjs/image/upload/v1628747763/love_2_lmpovo.png', 'https://res.cloudinary.com/dozqozwjs/image/upload/v1628747766/love_3_tfswx3.png', 'https://res.cloudinary.com/dozqozwjs/image/upload/v1628747759/love_1_azo6v7.png', 'https://res.cloudinary.com/dozqozwjs/image/upload/v1628747763/love_2_lmpovo.png' ]

    marker_images = {}

    ids.each_with_index do |id, index|
      marker_images[id] = urls[index]
    end
    # current_user = User.find_by_id(session[:current_user_id])
    # activities that the user choosed

    # raise

    @markers = @day[:day].activities.map do |activity|
      {
        next: true,
        lat: activity.latitude,
        lng: activity.longitude,
        info_window: render_to_string(partial: "info_window", locals: { activity: activity }),
        image_url: marker_images[activity.day_id]

      }
    end

    # binding.pry
        @city = @trip.city

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
    # calculate_day_plan
    day =  @trip.days[params[:day].to_i - 1]
    @day = { day: @trip.days[params[:day].to_i - 1], activities: Activity.where(day: day) }



    # @next = @result[params[:day].to_i] ? params[:day].to_i + 1 : nil
    # @prev = @next ? @next - 1 : params[:day].to_i - 1

    @next = params[:day].to_i + 1 unless params[:day].to_i == @trip.days.length
    @prev = params[:day].to_i - 1 unless params[:day].to_i == 1

    @result = [@day]


     activities = @trip.activities.where.not(day_id: nil)

    ids = activities.map { |act| act.day_id }.uniq

    urls = ['https://res.cloudinary.com/dozqozwjs/image/upload/v1628747759/love_1_azo6v7.png', 'https://res.cloudinary.com/dozqozwjs/image/upload/v1628747763/love_2_lmpovo.png', 'https://res.cloudinary.com/dozqozwjs/image/upload/v1628747766/love_3_tfswx3.png']

    marker_images = {}

    ids.each_with_index do |id, index|
      marker_images[id] = urls[index]
    end
    # current_user = User.find_by_id(session[:current_user_id])
    # activities that the user choosed

    @markers = @day[:day].activities.map do |activity|
      {
        lol: 2,
        lat: activity.latitude,
        lng: activity.longitude,
        info_window: render_to_string(partial: "info_window", locals: { activity: activity }),
        image_url: marker_images[activity.day_id]

      }
    end

    # binding.pry
        @city = @trip.city

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

    activities = @trip.activities.where.not(day_id: nil)

    ids = activities.map { |act| act.day_id }.uniq

    urls = ['https://res.cloudinary.com/dozqozwjs/image/upload/v1628747759/love_1_azo6v7.png', 'https://res.cloudinary.com/dozqozwjs/image/upload/v1628747763/love_2_lmpovo.png', 'https://res.cloudinary.com/dozqozwjs/image/upload/v1628747766/love_3_tfswx3.png']

    marker_images = {}

    ids.each_with_index do |id, index|
      marker_images[id] = urls[index]
    end
    # current_user = User.find_by_id(session[:current_user_id])
    # activities that the user choosed

    @markers = activities.map do |activity|
      {
        lat: activity.latitude,
        lng: activity.longitude,
        info_window: render_to_string(partial: "info_window", locals: { activity: activity }),
        image_url: marker_images[activity.day_id]

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

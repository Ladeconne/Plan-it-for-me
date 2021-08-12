class ActivitiesController < ApplicationController
  # before_activity :set_trip, only: %i[edit update]
  def index
    # Comment from 'begin' to 'end' if you are calling the API during your work

    places_list = AmadeusApiCall.new(session.dig(:city)).call
    places_list = filter_by_category(places_list)
    @activities = open_trip_map(places_list).sort_by { |_a, b| -b.length }.to_h
  # rescue StandardError => err
  #   flash[:alert] = "Oups, something went wrong, try again ;)"
  #   redirect_to root_path

    # comment first '@activities' and uncomment the next one if you are calling the API during your work
    # looping by category
    # @activities = open_trip_map(places_list).sort_by { |_a, b| -b.length }.to_h
    # @activities = { "Religion" => Activity.all.sample(8), "Museum" => Activity.all.sample(8) }
  end

  def show
    @activity = Activity.find(params[:id])
    respond_to do |format|
      format.json do
        render json: { modal: render_to_string("_modal", formats: [:html], layout: false,
                                                         locals: { activity: @activity }) }
      end
    end
  end

  def assign_day
    @activity = Activity.find(params[:id])
    @activity.update(day_id: params[:day_id])
    redirect_to @activity.trip
  end

  def remove_day
    @activity = Activity.find(params[:id])
    @activity.update(day_id: nil)
    redirect_to @activity.trip
  end

  private

  def filter_by_category(activities)
    # Get the categories chosen by the user
    categories = params[:search][:categories]
    categories.map! { |category| category&.capitalize }
    # result
    places_list = {}
    places_list = categories.map { |x| [x, []] }.to_h
    tags = Tag.includes(:category).where(categories: { name: categories })
    activities.each do |activity|
      activity["tags"].each do |tag|
        x = tags.find_by_word(tag)&.category&.name
        if categories.include?(x)
          places_list[x] << activity
          break
        end
      end
    end
    return places_list
  end

  def open_trip_map(activity_lists)
    new_activity_lists = {}
    activity_lists.keys.each do |category|
      new_activity_lists[category] = []
      # binsin
      activity_lists[category].each do |activity|
        lat = activity["geoCode"]["latitude"]
        lon = activity["geoCode"]["longitude"]

        coords = [lat, lon]

        radius = 10_000 # 10000 metre around the coordinates given by Amadeus
        url = "https://api.opentripmap.com/0.1/en/places/radius?radius=#{radius}&lon=#{lon}&lat=#{lat}&apikey=" + ENV["OPEN_TRIP_MAP_KEY"]
        response = JSON.parse(RestClient.get(url))
        id = response['features'].first['properties']['xid']
        place_url = "http://api.opentripmap.com/0.1/en/places/xid/#{id}?apikey=" + ENV["OPEN_TRIP_MAP_KEY"]
        response = JSON.parse(RestClient.get(place_url))

        next if create_activity(response, coords).nil?

        activity = create_activity(response, coords)
        activity.save
        session[:activity_ids] = [*session[:activity_ids], activity.id]
        category_instance = Category.find_by_name(category)
        ActivityCategory.find_or_create_by(category: category_instance, activity: activity)
        new_activity_lists[category] << activity # activity object
      end
    end
    return new_activity_lists
  end

  def create_activity(activity_otm, coords)
    return if activity_otm["name"].empty?

    activity = Activity.new
    activity.name = activity_otm["name"]
    if activity_otm["url"]
      activity.link = activity_otm["url"].split(";").first
    else
      query = activity_otm["name"].gsub(" ", "-")
      activity.link = "https://www.google.fr/search?q=#{query}"
    end
    if activity_otm["preview"]
      activity.picture_url = activity_otm["preview"]["source"]
    else
      query = activity_otm["name"].gsub(" ", "-")
      activity.picture_url = "https://source.unsplash.com/400x300/?#{query}"
    end
    if activity_otm["wikipedia_extracts"]
      activity.description = activity_otm["wikipedia_extracts"]["text"]
    else
      activity.description = "Oups! Sorry we haven't find a specific description for this page, follow the link to have some on google :)"
    end
    activity.address = "#{activity_otm['address']['pedestrian']}, #{activity_otm['address']['city']}, #{activity_otm['address']['country']}"
    activity.latitude = coords[0]
    activity.longitude = coords[1]
    return activity
  end
end

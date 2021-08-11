class ActivitiesController < ApplicationController
  # before_activity :set_trip, only: %i[edit update]
  def index
    # Do not uncomment until production (call_amadeus is using our quota)
    begin
      places_list = AmadeusApiCall.new(session.dig(:city)).call
      places_list = filter_by_category(places_list)
      @activities = open_trip_map(places_list)
    rescue
      flash[:alert] = "Oups, something went wrong, try again ;)"
      redirect_to root_path
    end
    # This activity lists is the result we had when callig amadeus and filtering by Religion and Museum
    # activity_lists = {
    #   "Religion" => [
    #     { "type" => "location", "subType" => "POINT_OF_INTEREST", "id" => "AA8E41776E",
    #       "self" => { "href" => "https://test.api.amadeus.com/v1/reference-data/locations/pois/AA8E41776E", "methods" => ["GET"] }, "geoCode" => { "latitude" => 48.852966, "longitude" => 2.349902 }, "name" => "Cathédrale Notre-Dame de Paris", "category" => "SIGHTS", "rank" => 5, "tags" => ["church", "sightseeing", "restaurant", "tourguide", "sights", "temple", "landmark", "historicplace", "historic", "attraction", "activities", "professionalservices", "sports", "bike", "rental", "commercialplace", "outdoorplace"] }, { "type" => "location", "subType" => "POINT_OF_INTEREST", "id" => "13D98F7D12", "self" => { "href" => "https://test.api.amadeus.com/v1/reference-data/locations/pois/13D98F7D12", "methods" => ["GET"] }, "geoCode" => { "latitude" => 48.84681, "longitude" => 2.337546 }, "name" => "Jardin du Luxembourg", "category" => "SIGHTS", "rank" => 5, "tags" => ["sightseeing", "restaurant", "tourguide", "sights", "park", "landmark", "historicplace", "historic", "garden", "attraction", "activities", "hiking", "beauty&spas", "theater", "commercialplace", "nature"] }, { "type" => "location", "subType" => "POINT_OF_INTEREST", "id" => "521DE91E65", "self" => { "href" => "https://test.api.amadeus.com/v1/reference-data/locations/pois/521DE91E65", "methods" => ["GET"] }, "geoCode" => { "latitude" => 48.88672, "longitude" => 2.343002 }, "name" => "Basilique du Sacré-Cœur de Montmartre", "category" => "SIGHTS", "rank" => 5, "tags" => ["church", "sightseeing", "sights", "temple", "landmark", "tourguide", "restaurant", "attraction", "commercialplace", "activities", "professionalservices"] }, { "type" => "location", "subType" => "POINT_OF_INTEREST", "id" => "E565F32CAE", "self" => { "href" => "https://test.api.amadeus.com/v1/reference-data/locations/pois/E565F32CAE", "methods" => ["GET"] }, "geoCode" => { "latitude" => 48.925682, "longitude" => 2.359429 }, "name" => "Stade de France", "category" => "SIGHTS", "rank" => 5, "tags" => ["stadium", "sightseeing", "tourguide", "landmark", "historicplace", "sights", "historic", "activities", "sports", "events", "shopping", "restaurant", "outdoorplace", "commercialplace", "attraction"] }
    #   ], "Museum" => [{ "type" => "location", "subType" => "POINT_OF_INTEREST", "id" => "EC7AE15DF5", "self" => { "href" => "https://test.api.amadeus.com/v1/reference-data/locations/pois/EC7AE15DF5", "methods" => ["GET"] }, "geoCode" => { "latitude" => 48.860825, "longitude" => 2.352633 }, "name" => "Centre Pompidou", "category" => "SIGHTS", "rank" => 5, "tags" => ["museum", "sightseeing", "restaurant", "artgallerie", "tourguide", "sights", "transport", "activities", "attraction", "shopping", "square", "parking", "professionalservices", "bus", "theater", "events", "commercialplace"] }]
    # }
    # looping by category
    # @activities = { "Religion" => Activity.all.sample(3), "Museum" => Activity.all.sample(4) }
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
      activity_lists[category].each do |activity|
        lat = activity["geoCode"]["latitude"]
        lon = activity["geoCode"]["longitude"]
        radius = 10_000 # 10000 metre around the coordinates given by Amadeus
        url = "https://api.opentripmap.com/0.1/en/places/radius?radius=#{radius}&lon=#{lon}&lat=#{lat}&apikey=" + ENV["OPEN_TRIP_MAP_KEY"]
        response = JSON.parse(RestClient.get(url))
        id = response['features'].first['properties']['xid']
        place_url = "http://api.opentripmap.com/0.1/en/places/xid/#{id}?apikey=" + ENV["OPEN_TRIP_MAP_KEY"]
        response = JSON.parse(RestClient.get(place_url))

        unless create_activity(response).nil?
          activity = create_activity(response)
          activity.save
          session[:activity_ids] = [*session[:activity_ids], activity.id]
          category_instance = Category.find_by_name(category)
          ActivityCategory.find_or_create_by(category: category_instance, activity: activity)
          new_activity_lists[category] << activity # activity object
        end
      end
    end
    return new_activity_lists
  end

  def create_activity(activity_otm)
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
    activity.address = "#{activity_otm['address']['pedestrian']}, #{activity_otm['address']['city']}, #{activity_otm['address']['country']}}"
    activity.latitude = activity_otm["point"]["lat"]
    activity.longitude = activity_otm["point"]["lon"]
    return activity
  end
end

class ActivitiesController < ApplicationController
  def index
    call_amadeus
  end

  private

  def call_amadeus
    # test token
    token = "srkQZJZcMULG8KcGWwg2wff86avN"
    # Get the city
    city = session[:city]
    # find the longitude and latitude, define the radius
    data = Geocoder.search(city).first&.data
    long = data["lon"]
    lat = data["lat"]
    radius = 10
    # build the url
    url = "https://test.api.amadeus.com/v1/reference-data/locations/pois?latitude=#{lat}&longitude=#{long}&radius=#{radius}"
    # Calling the API
    response = JSON.parse(RestClient.get(url, { Authorization: "Bearer #{token}" }))
    data = response["data"]
    binding.pry
    filter_by_category(data)
  end

  def filter_by_category(activities)
    # Get the categories chosen by the user
    categories = params[:search][:categories][1..-1]
    binding.pry
    # result
    activity_lists = {}
    categories.each do |cat|
      category_activities = []
      activities.each do |activity|
        activity["tags"].each do |tag|
          if Tag.find_by_word(tag) && Tag.find_by_word(tag).category == cat
            category_activities << activity
            p category_activities
          end
          break if category_activities.size == 5
        end
        break if category_activities.size == 5
      end
      activity_lists[cat] = category_activities
    end
    p activity_lists
  end

  def open_trip_map(lat, long)
  end
end

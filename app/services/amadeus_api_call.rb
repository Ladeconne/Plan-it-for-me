class AmadeusApiCall
  def initialize(location)
    @amadeus = Amadeus::Client.new(client_id: AMADEUS_CLIENT_ID, client_secret: AMADEUS_CLIENT_SECRET, hostname: :production)
    @location = location
  end

  def call

    # # test token
    # token = "A3GnGCHlA6qPfeKcXAp24gcgssgP"
    # # Get the city
    # city = @location
    # # find the longitude and latitude, define the radius
    # data = Geocoder.search(city).first&.data
    # p data
    # long = data["lon"]
    # lat = data["lat"]
    # radius = 10
    # # build the url
    # url = "https://api.amadeus.com/v1/reference-data/locations/pois?latitude=#{lat}&longitude=#{long}&radius=#{radius}&page[limit]=20"
    # # Calling the API
    # response = JSON.parse(RestClient.get(url, { Authorization: "Bearer #{token}" }))
    # byebug
    # data = response["data"]

    # response = @amadeus.reference_data.locations.points_of_interest.get(**get_lat_long, limit: 50)
    #      byebug
    # p response
    # response.data.map { |result| result.slice("geoCode", "tags")}
    # data = []
    response = @amadeus.reference_data.locations.points_of_interest.get(**get_lat_long, page: { limit: 40 }, radius: 10)
    response.data.map { |result| result.slice("geoCode", "tags")}.uniq
    rescue  => e
    return []
  end

  private

  def get_lat_long
    data = Geocoder.search(@location).first&.data
    return { latitude: data["lat"], longitude: data["lon"]}
  end
end

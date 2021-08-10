class AmadeusApiCall
  def initialize(location)
    # for production call add the following attribute as argument of new ==> hostname: :production
    case Rails.env
    when "development"
      @amadeus = Amadeus::Client.new(client_id: AMADEUS_CLIENT_ID, client_secret: AMADEUS_CLIENT_SECRET)
    when "production"
      @amadeus = Amadeus::Client.new(client_id: AMADEUS_CLIENT_ID, client_secret: AMADEUS_CLIENT_SECRET, hostname: :production)
    end
    @location = location
  end

  def call
    # Add the attribute  of production
    response = @amadeus.reference_data.locations.points_of_interest.get(**get_lat_long, page: { limit: 40 }, radius: 10)
    response.data.map { |result| result.slice("geoCode", "tags") }.uniq
  end

  private

  def get_lat_long
    data = Geocoder.search(@location).first&.data
    return { latitude: data["lat"], longitude: data["lon"]}
  end
end

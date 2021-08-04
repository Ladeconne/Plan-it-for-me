class TripsController < ApplicationController


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
    @days = (Date.today..(Date.today + 4)).to_a
    # city the user choose
    @city = ['Marseille', 'Paris', 'Lyon', 'Nice', 'Reims'].sample
  end

  def fake_activities
    @activities = []
    rand(4..8).times do
    # session[:activities].each do
    activity = Activity.new(
               picture_url: 'https://images.unsplash.com/photo-1508180588132-ec6ec3d73b3f?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80.png',
               name: ['A Museum', 'B Museum', 'X park', 'X Sprt Ground', 'X Church'].sample,
               description: 'This is a beatiful place.',
               link: 'https://en.wikipedia.org/wiki/Rue_de_Rivoli',
               address: ['Rue de Rivoli, 75001 Paris', "1 Rue de la Légion d'Honneur, 75007 Paris", "Esplanade de Fourvière, 69005 Lyon", "86 Quai Perrache, 69002 Lyon", 'Av. de Corinthe, 13010 Marseille', '84 Av. Georges Clemenceau, 51100 Reims'].sample,
               favourite: false,
               trip: nil,
               day: nil)
    activity.geocode
    @activities << activity if activity.latitude
    end
  end

end

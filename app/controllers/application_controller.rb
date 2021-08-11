class ApplicationController < ActionController::Base
  # before_action :authenticate_user!

  def after_sign_in_path_for(user)
    if session[:trip_id]
      trip = Trip.find(session[:trip_id])
      trip.user = user
      trip.save
      session.delete(:trip_id)
      trip_path(trip)
    else
      stored_location_for(resource) || root_path
    end
  end
end

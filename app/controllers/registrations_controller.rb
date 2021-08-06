class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(user)
    if session[:trip_id]
      trip = Trip.find(session[:trip_id])
      trip.user = user
      trip.save
      session.delete(:trip_id)
      trip_path(trip)
    else
      stored_location_for(user)
    end
  end
end

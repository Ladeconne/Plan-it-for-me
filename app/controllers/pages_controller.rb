class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]

  def home
    session[:current_trip] = nil
  end

  def components
  end
end

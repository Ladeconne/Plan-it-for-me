class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]
  before_action :clear_session, only: [ :home ]

  def home
    session[:current_trip] = nil
  end

  def components
  end

  private

  def clear_session
    session[:current_trip] = nil
  end
end

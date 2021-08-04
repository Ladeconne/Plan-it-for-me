class CategoriesController < ApplicationController

  def index
    unless valid?
      render 'pages/home'
      return
    end
    session[:city] = params.dig(:search, :city)
    session[:start_date] = params.dig(:search, :start_date)
    session[:end_date] = params.dig(:search, :end_date)
  end


  private

  def valid?
    unless params.dig(:search, :city).present?
      @errors = { city: 'Please add a valid location'}
      return false
    end
    unless params.dig(:search, :start_date).present?
      @errors = { start_date: 'Please add a valid start date'}
      return false
    end
    unless params.dig(:search, :end_date).present? && params.dig(:search, :start_date) < params.dig(:search, :end_date)
      @errors = { end_date: 'Please add a valid end date'}
      return false
    end


    # Finish with validating start and end date.



    true
  end

end

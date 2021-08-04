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
    @today = Date.today
    unless params.dig(:search, :city).present?
      @errors = { city: 'Please add a valid location'}
      return false
    end
    unless params.dig(:search, :start_date).present?
      @errors = { start_date: 'Please add a start date'}
      return false
    end
    unless params.dig(:search, :start_date).to_date >= @today
      @errors = { start_date: 'Cant choose a date in the past'}
      return false
    end
    unless params.dig(:search, :end_date).present?
      @errors = { end_date: 'Please add an end date'}
      return false
    end
    unless params.dig(:search, :start_date) <= params.dig(:search, :end_date)
      @errors = { end_date: 'Cant choose a date before the start date'}
      return false
    end


    # Finish with validating start and end date.



    true
  end

end

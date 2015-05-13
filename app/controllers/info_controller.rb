class InfoController < ApplicationController
  include InfoRepresentor

  def index
  	render json: welcome_message
  end

  def users
  end

  def tweets
  end

  def topics
  end
end

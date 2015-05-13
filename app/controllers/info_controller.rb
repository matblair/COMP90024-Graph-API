class InfoController < ApplicationController
  include InfoRepresentor

  def index
  	render json: welcome_message(Tweet.count, User.count, Topic.count)
  end

end

class Api::TopicsController < ApplicationController

	before_all :find_topic
	
	def show
	
	end
	
	def similar


	end

	private
	def find_topic
		@topic = Topic.find_by(tag: params[:id])
	end

end

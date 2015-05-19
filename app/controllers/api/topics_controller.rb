class Api::TopicsController < ApplicationController
	include TopicsRepresentor
	
	before_action :find_topic
	
	# We want to return information about the topic 
	def show
		referenced = @topic.tweets.count(:distinct)
		users = @topic.tweets.user.count(:distinct)
		render json: show_json(@topic, referenced, users)
	end
	
	def similar
		# Find the degree
		if params.has_key? 'degree'
			# Can only be one two or three
			degree = params['degree'].to_i
			if degree < 0
				degree = 0
			elsif degree >= 3
				degree = 2
			end
		else
			degree = 0
		end

		# Build the query 
		case degree
		when 0 
			topics = @topic.tweets.topics.collect {|t| t.tag }.uniq
		when 1
			topics = @topic.tweets.user.tweets.topics.collect {|t| t.tag }.uniq
		when 2
			topics = @topic.tweets.user.tweets.topics.tweets.user.tweets.topics.collect {|t| t.tag }.uniq
		end

		# Return the query
		render json: similar_json(@topic, topics, degree)
	end

	private
	def find_topic
		@topic = Topic.find_by(tag: params[:id])
		if !@topic
			render json: error_msg(params[:id])
		end
	end

end

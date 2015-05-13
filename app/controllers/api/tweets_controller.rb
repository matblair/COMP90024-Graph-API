class Api::TweetsController < ApplicationController
	include TweetRepresentor

	require 'tweet_importer'

	def submit
		# Find tweets
		tweets = params[:tweets]
		# Process each tweet with the tweet importer
		errors = TweetImporter.import_tweets tweets
		# Render 
		if errors
			render json: {:errors => errors, :msg => "#{tweets.count - errors.count} Tweets succesfully imported."}.to_json
		else
			render json: {:message => "All tweets succesfully imported"}.to_json
		end
	end


	def index
		render json: Tweet.all
	end
end

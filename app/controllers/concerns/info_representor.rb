module InfoRepresentor
	extend ActiveSupport::Concern

	def welcome_message(tweet_count, user_count, topic_count)
		{
		 :message => "Welcome to San Antonio Twitter Information Services",
		 :time => "#{Time.now}"
		 :tweets => "tweet_count",
		 :users => "user_count",
		 :topics => "topic_count"
		}.to_json
	end

end

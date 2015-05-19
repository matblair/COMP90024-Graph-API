module TopicsRepresentor
	extend ActiveSupport::Concern

	def similar_json(topic, topics, degree)
		{
		 :topic => topic.tag,
		 :tweet_references => topic.tweets.count,
		 :user_references => topic.tweets.user.count(:distinct),
		 :degree => degree,
		 :similar => topics
		}.to_json
	end

	def show_json(topic, count, count_users)
		{
			:topic => topic.tag,
			:tweet_references => count,
			:unique_users => count_users
		}.to_json
	end

	def error_msg(topic)
		{
			:error => "Could not find information about #{topic}"
		}.to_json
	end


end

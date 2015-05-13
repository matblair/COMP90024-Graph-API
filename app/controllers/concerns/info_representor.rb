module InfoRepresentor
	extend ActiveSupport::Concern

	def welcome_message
		{
		 :message => "Welcome to San Antonio Twitter Information Services",
		 :time => "#{Time.now}"
		}.to_json
	end

end

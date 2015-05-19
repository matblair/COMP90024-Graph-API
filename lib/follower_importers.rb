# Imports user followers by reading in a csv of user follower
# details and then saving those relations in neo4j
require 'csv'

def add_follower user_id, follower_id
  u = User.find_by(twitter_id: user_id.to_s)
  f = User.find_by(twitter_id: follower_id.to_s)

  if f && u
  	if !(u.followers.include? f)
	    u.followers << f
	    u.save
	    return true
	else
		return false
	end
  end
end

def process_user_line user_id, followers
	count = 0
	fol_array = followers.strip.split(" ")
	fol_array.each do |f_id|
		if add_follower user_id, f_id
			count += 1
		end
	end
	count
end

# Read in the file
user_follwers = ARGV[0]

# Open the file as csv with headers
CSV.foreach(user_follwers, headers:true).each do |line|
	count = process_user_line line['user_id'], line['followers']
	puts "Successfully imported #{count} out of #{line['followers'].split(" ").count} followers for #{line['user_id']}"
end

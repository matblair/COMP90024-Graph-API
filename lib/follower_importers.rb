# Imports user followers by reading in a csv of user follower
# details and then saving those relations in neo4j

def add_follower user_id, follower_id
  u = User.find_by(twitter_id: user_id.to_s)
  f = User.find_by(twitter_id: follower_id.to_s)
  if f && u
    u.followers << f
    u.save
  end
end

def process_user_line user_id, followers
	fol_array = followers.strip.split(" ")
	fol_array.each do |f_id|
		add_follower user_id, f_id
	end
end

# Read in the file
user_follwers = ARGV[0]

# Open the file as csv with headers
CSV.foreach(user_follwers, headers:true).each do |line|
	process_user_line line['user_id'], line['followers']
end

# Require appropriate files
require 'tweet_importer'
require 'net/http'
require 'json'

BUNCH_MAX = 100
GRAPH_IP = '144.6.227.66'
GRAPH_PORT = 4500

# Find the file and duplicates
file = ARGV[0]

def upload_tweets tweets
  # Create a new connection object to couch
  http = Net::HTTP.new(COUCH_IP, COUCH_PORT)

  # Create the hash
  payload = {:tweets => tweets}

  # Upload
  response = http.send_request('PUT', "/api/tweets/submit", payload.to_json)
  puts response
end


count = 0
# Open that file
File.open(file, 'r') do |f|
  tweets = []
  while line = f.gets
    begin
      j = JSON.parse line
      tweets << j
      count += 1
      if tweets.count >= BUNCH_MAX
        errors = upload_tweets tweets
        if errors
          $stdout.puts "Succesfully imported #{tweets.count - errors.count} tweets (#{count} in total)"
        else
          $stdout.puts "Succesfully imported #{tweets.count} tweets (#{count} in total)"
        end
        tweets = []
      end
    rescue Exception => e
      $stderr.puts e
      $stderr.puts "Cannot parse json for line"
    end
  end

  if not tweets.empty?
    TweetImporter.import_tweets tweets
    $stdout.puts "Succesfully imported #{tweets.count} tweets"
  end

  $stdout.puts "Succesfully imported a total of #{count} tweets."

end
## Import a csv full of tweets

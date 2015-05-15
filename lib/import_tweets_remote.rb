# Require appropriate files
require 'net/http'
require 'json'

BUNCH_MAX = 10
GRAPH_IP = '144.6.227.66'
GRAPH_PORT = 4500

# Find the file and duplicates
file = ARGV[0]

def upload_tweets tweets
  # Create a new connection object to couch
  http = Net::HTTP.new(GRAPH_IP, GRAPH_PORT)

  # Create the hash
  payload = {:tweets => tweets}
  # Upload
  response = http.request_post("/api/tweets/submit", payload.to_json, initheader = {'Content-Type' =>'application/json'})
  response = JSON.parse response.body
  response['errors']
end

count = 0
# Open that file
File.open(file, 'r') do |f|
  tweets = []
  imported=0
  while line = f.gets
    # begin
    j = JSON.parse line
    tweets << j
    count += 1
    if tweets.count >= BUNCH_MAX
      errors = upload_tweets tweets
      if errors
        s = tweets.count - errors.count
        imported += (s)
        $stdout.puts "Succesfully imported #{s} tweets (#{imported} out of #{count} in total)"
      else
        imported += tweets.count
        $stdout.puts "Succesfully imported #{tweets.count} tweets (#{imported} out of #{count} in total)"
      end
      tweets = []
    end
    # rescue
    #   $stderr.puts "Cannot parse json for line"
    # end
  end

  if not tweets.empty?
    errors = upload_tweets tweets
    if errors
      s = tweets.count - errors.count
      imported += (s)
      $stdout.puts "Succesfully imported #{s} tweets (#{imported} out of #{count} in total)"
    else
      imported += tweets.count
      $stdout.puts "Succesfully imported #{tweets.count} tweets (#{imported} out of #{count} in total)"
    end
  end

  $stdout.puts "Succesfully imported a total of #{imported} tweets."

end
## Import a csv full of tweets

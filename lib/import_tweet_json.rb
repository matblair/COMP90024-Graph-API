# Require appropriate files
require 'tweet_importer'

BUNCH_MAX = 300
COUCH_TWEET_DB = 'twitter_tweets'

# Find the file and duplicates
file = ARGV[0]

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
        errors = TweetImporter.import_tweets tweets
        $stdout.puts "Succesfully imported #{tweets.count - errors.count} tweets (#{count} in total)"
        tweets = []
      end
    rescue Exception => e
      puts e
      $stderr.puts "Cannot parse json for line"
    end
  end

  if not tweets.empty?
    TweetImporter.import_tweets tweets
    $stdout.puts "Succesfully imported #{tweets.count} tweets"
  end

  $stdout.puts "Succesfully imported a total of #{count} tweets."

end

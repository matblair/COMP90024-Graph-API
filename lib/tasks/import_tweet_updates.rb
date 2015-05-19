# Require appropriate files
require 'couch_updater'

BUNCH_MAX = 300
COUCH_TWEET_DB = 'tweet_test2'

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
        errors = CouchUpdater.update_documents tweets, COUCH_TWEET_DB, 'id'
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
    errors = CouchUpdater.update_documents tweets, COUCH_TWEET_DB, 'id'
    $stdout.puts "Succesfully imported #{tweets.count} tweets"
  end

  $stdout.puts "Succesfully imported a total of #{count} tweets."

end

class TweetImporter
  require 'couch_uploader'

  HASHTAG_KEY    = "hashtags"
  MENTION_KEY    = "user_mentions"
  TWEET_ID_KEY   = "id"
  USER_KEY       = "user"
  CREATED_AT_KEY = "created_at"

  RETWEET_KEY    = "retweeted"

  COUCH_TWEET_DB = 'twitter_tweets'

  def self.import_tweets tweets
    ## Process each tweet as if it has the correct structure
    ## and then upload to couchdb if save is correct
    to_couch = []
    errors = []

    tweets.each do |tweet_hash|
      begin
        ## Create the tweet
        tweet_id  = tweet_hash[TWEET_ID_KEY]
        retweeted = tweet_hash[RETWEET_KEY]

        tweet = Tweet.new(twitter_id: tweet_id,
                          retweet: retweeted)

        # Check if we have a tweet
        if tweet.save
          # Is unique so build relationships
          find_tweeters tweet, tweet_hash
          find_topics tweet, tweet_hash
          find_mentions tweet, tweet_hash

          # Parse the date
          d = DateTime.parse(tweet_hash[CREATED_AT_KEY])
          # Build json for that
          date_hash = {day: d.day, month: d.month, year: d.year,
                       hour: d.hour, minute: d.minute,
                       string: tweet_hash[CREATED_AT_KEY]}
          # Assign it
          tweet_hash[CREATED_AT_KEY] = date_hash


          # Push to couch for tweet content storage
          to_couch << tweet_hash
        else
          errors << tweet.errors
        end
      rescue Exception => e
        $stderr.puts e
        # Just incase the above throws an exception (which it shouldn't...)
        errors << tweet_hash
      end
    end

    # Upload all things to couch if there is anything
    if to_couch.count > 0
      CouchUploader.upload_documents to_couch, COUCH_TWEET_DB, TWEET_ID_KEY
    end
    # Return nil if no errors
    errors.empty? ? nil : errors
  end

  # Functions to build tweet relationships
  private
  def self.find_tweeters tweet, tweet_hash
    if (tweet_hash.has_key? USER_KEY) && (tweet_hash[USER_KEY])
      user = tweet_hash[USER_KEY]
      u = User.find_or_create_by!(twitter_id: user["id"], screen_name: user["screen_name"])
      u.tweets << tweet
      u.save
    end
  end

  def self.find_topics tweet, tweet_hash
    if (tweet_hash.has_key? HASHTAG_KEY) && (tweet_hash[HASHTAG_KEY])
      topics = tweet_hash[HASHTAG_KEY]
      topics.each do |topic|
        text = topic['text']
        t = Topic.find_or_create_by!(tag: text)
        t.tweets << tweet
        t.save
      end
    end
  end

  def self.find_mentions tweet, tweet_hash
    if (tweet_hash.has_key? MENTION_KEY) && tweet_hash[MENTION_KEY]
      mentions = tweet_hash[MENTION_KEY]
      mentions.each do |mention|
        u = User.find_or_create_by!(twitter_id: mention["id"],
                                    name: mention["name"])
        u.mentions << tweet
        u.save
      end
    end
  end



end

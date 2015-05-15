class TweetImporter
  require 'couch_uploader'

  HASHTAG_KEY     = 'hashtags'
  MENTION_KEY     = 'user_mentions'
  ID_KEY          = 'id'
  USER_KEY        = 'user'
  CREATED_AT_KEY  = 'created_at'
  REPLY_KEY       = 'in_reply_to_status_id'
  RETWEET_KEY     = 'retweeted'
  USER_REPLY_KEY  = 'in_reply_to_user_id'
  USER_REPLY_NAME = 'in_reply_to_screen_name'
  COUCH_TWEET_DB  = 'tweets'
  COUCH_USER_DB   = 'twitter_users'

  def self.import_tweets tweets
    ## Process each tweet as if it has the correct structure
    ## and then upload to couchdb if save is correct
    to_couch = []
    errors = []
    users = []

    tweets.each do |tweet_hash|
      begin

        ## Create the tweet
        tweet_id  = tweet_hash[ID_KEY]
        retweeted = tweet_hash[RETWEET_KEY]
        if retweeted.eql? "false"
          retweeted = false
        else
          retweeted = true
        end

        tweet = Tweet.new(twitter_id: tweet_id,
                          retweet: retweeted,
                          in_couch: true)
        # Check if we have a tweet
        if tweet.save
          entities = tweet_hash["entities"]
          # Is unique so build relationships
          user = find_tweeters tweet, tweet_hash
          find_topics tweet, entities
          find_mentions tweet, entities
          find_replies tweet, user, tweet_hash
          if (tweet_hash.has_key? USER_REPLY_KEY) && tweet_hash[USER_REPLY_KEY]
            associate_tweet tweet_hash[USER_REPLY_KEY], tweet_hash[REPLY_KEY]
          end

          # Extract the user info for couch
          if tweet_hash.has_key? USER_KEY
            users << tweet_hash[USER_KEY]
          end

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
        puts e
        # Just incase the above throws an exception (which it shouldn't...)
        errors << tweet_hash
      end
    end

    # Upload all things to couch if there is anything
    if to_couch.count > 0
      CouchUploader.upload_documents users, COUCH_USER_DB, ID_KEY
      CouchUploader.upload_documents to_couch, COUCH_TWEET_DB, ID_KEY
    end
    puts "errors are #{errors.to_s}"

    # Return nil if no errors
    errors.empty? ? nil : errors
  end

  # Functions to build tweet relationships
  private
  def self.find_tweeters tweet, tweet_hash
    if (tweet_hash.has_key? USER_KEY) && (tweet_hash[USER_KEY])
      user = tweet_hash[USER_KEY]
      u = User.find_by(twitter_id: user["id"].to_s)
      if !u
        u = User.new(twitter_id: user["id"], name: user["name"], in_couch: true, screen_name: user["screen_name"])
      else
        # Found user so make sure we flag them as in couch
        u.in_couch = true
      end
      u.save
      u.tweets << tweet
      u.save
      return u
    end
  end

  def self.find_replies tweet, user, tweet_hash
    if (tweet_hash.has_key? REPLY_KEY) && (tweet_hash[REPLY_KEY])
      reply_to_tweet = Tweet.find_by(twitter_id: tweet_hash[REPLY_KEY].to_s)
      ## CHECK IF THE TWEET DOESN'T EXIT
      if !reply_to_tweet
        reply_to_tweet = Tweet.new(twitter_id: tweet_hash[REPLY_KEY], in_couch: false)
        reply_to_tweet.save
      end

      # Associate all the things~!~!!!!!!~~!!~1~!!~!~!~!1~
      reply_to_user = User.find_by(twitter_id: tweet_hash[USER_REPLY_KEY].to_s)
      if !reply_to_user
        reply_to_user = User.new(twitter_id: tweet_hash[USER_REPLY_KEY], screen_name: tweet_hash[USER_REPLY_NAME], in_couch: false)
        reply_to_user.save
      end

      reply_to_tweet.replies << tweet
      reply_to_tweet.save
    end
  end

  def self.associate_tweet user_id, tweet_id
    t = Tweet.find_by(twitter_id: tweet_id.to_s)
    u = User.find_by(twitter_id: user_id.to_s)
    if t && u 
      u.tweets << t
      u.save
    end
  end

  def self.find_topics tweet, entities
    if (entities.has_key? HASHTAG_KEY) && (entities[HASHTAG_KEY])
      topics = entities[HASHTAG_KEY]
      topics.each do |topic|
        text = topic['text']
        t = Topic.find_or_create_by!(tag: text)
        t.tweets << tweet
        t.save
      end
    end
  end

  def self.find_mentions tweet, entities
    if (entities.has_key? MENTION_KEY) && entities[MENTION_KEY]
      mentions = entities[MENTION_KEY]
      mentions.each do |mention|

        u = User.find_by(twitter_id: mention["id"].to_s)
        if !u
          u = User.new(twitter_id: mention["id"],
                       name: mention["name"],
                       screen_name: mention["screen_name"],
                       in_couch: false)
          u.save
        end
        u.mentions << tweet
        u.save
      end
    end
  end



end

class User
  include Neo4j::ActiveNode

  # Properties
  property :name, type: String
  property :screen_name, type: String
  property :twitter_id,  type: String, index: :exact, constraint: :unique
  property :language,    type: String, index: :exact
  property :sleuthed,    type: Boolean
  property :in_couch, type: Boolean

  # Validations for uniqueness contrainsts
  validates_uniqueness_of :twitter_id
  validates :twitter_id, :presence => true

  # Named relationships
  has_many :out, :tweets, type: 'tweeted'
  has_many :out, :follows, model_class: User, origin: :followers
  has_many :in, :followers, model_class: User, type: "follows"
  has_many :in, :mentions, model_class: Tweet, type: "mentions"

end
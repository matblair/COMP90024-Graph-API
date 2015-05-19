class Api::UsersController < ApplicationController
  include UserRepresentor

  before_action :find_users, only: [:shortest_path]
  before_action :validate_input, only: [:shortest_path]

  def shortest_path
    # Find the limit
    if params.has_key? 'limit'
      limit = params['limit']
    else
      limit = 10
    end

    ## Find the path
    query_string = "MATCH (a:User {twitter_id:'#{@start}'}),(b:User {twitter_id:'#{@end}'}), p = shortestPath((a)-[*]-(b)) RETURN a,b,p LIMIT #{limit}"
    puts query_string
    path = Neo4j::Session.query(query_string)

    ## Check the path lenght
    if path.count > 0
      render json: path_json(path.to_a)
    else
      render json: {:error => "couldn't find a path between #{@start} and #{@end}}"}
    end
  end

  def connections
    @u = User.find_by(twitter_id: params['user_id'].to_s)
    if !@u
      render json: {:error => "Invalid user" }
    end

    # Find degree
    if params.has_key? 'degree'
      degree = (params['degree'].to_i > 3) ? 3 : params['degree'].to_i
    else
      degree = 1
    end

    puts degree
    # Get the array of users
    users = find_connections @u, degree

    render json: connections_json(@u, users)
  end

  private

  def find_connections u, degree
    f = u.followers
    response = { 0 => f.to_a }
    puts response.keys
    # Add the extra ones
    (degree-1).times do |i|
      current = f.followers
      response[(i+1)] = current.to_a - f.to_a
          puts response.keys

      f = current
    end
    response
  end



  def validate_input
    if not ((params.has_key? 'user_one') and (params.has_key? 'user_two'))
      render json: {:message => 'need two user ids'}
    end
  end

  def find_users
    @start = params['user_one']
    @end = params['user_two']
  end

end

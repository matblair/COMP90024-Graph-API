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

	private 

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

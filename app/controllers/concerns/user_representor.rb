module UserRepresentor
	extend ActiveSupport::Concern

	def path_json path
		nodes = {}
		count = 0
		path.each do |elem|
			# Extract the user 
			u = elem.a
			node = {}
			node['user'] = user_json(u)
			if count < (path.count - 1)
				node['direction'] = elem.p['directions'].first.eql?('-\u003e') ? '->' : '<-'
			else
				node['direction'] = 'null'
			end
			# Put it in the nodes
			nodes[count] = node
			count += 1
		end

		# Build the response
		response = {:nodes => nodes, :path => path.first.p['directions'].join(" "), :path_length => path.count}
		response.to_json
	end


	def user_json user
		{
			:name => user.name,
			:twitter_id => user.twitter_id,
			:in_couch => user.in_couch
		}
	end


end

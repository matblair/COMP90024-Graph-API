# config valid only for Capistrano 3.4
lock '3.4.0'
set :application, 'graph_api'
set :repo_url, 'git@github.com:matblair/COMP90024-Graph-Api.git'

set :deploy_to, '/webapps/graph_api'
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :bundle_dir, ""
set :bundle_flags, ""

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
    	execute "service thin restart"  ## -> line you should add
    end
  end

  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'
end

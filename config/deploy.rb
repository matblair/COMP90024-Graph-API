# config valid only for Capistrano 3.1
lock '3.1.0'
set :application, 'graph_api'
set :repo_url, 'git@github.com:matblair/COMP90024-Graph-Api.git'

set :deploy_to, '/webapps/graph_api'
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      run "cd #{current_path} && thin stop"
      run "cd #{current_path} && thin start -p 4500"
    end
  end

  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'
end

lock "~> 3.19.2"

set :application, "neogopingbus"
set :repo_url, "git@github.com:pankajroy4/neo_go_ping_bus.git"

set :rvm_type, :user
set :rvm_ruby_version, "3.2.0"

set :branch, "main" 

set :deploy_to, "/home/ubuntu/apps/#{fetch(:application)}"

set :default_env, {
  PATH: "/home/ubuntu/.nvm/versions/node/v18.20.5/bin:$PATH"
}

# append :linked_files, "config/database.yml", 'config/master.key' ,'config/credentials/production.key'
append :linked_files, "config/database.yml", "config/master.key" ,"config/credentials.yml.enc"

append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"

set :keep_releases, 2

set :ssh_options, {
  keys: %w(/home/user/.ssh/pankaj_deploy.pem),
  forward_agent: false,
  auth_methods: %w(publickey)
}
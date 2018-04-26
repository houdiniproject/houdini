# config valid for current version and patch releases of Capistrano
lock "~> 3.10.2"

set :application, "houdini"
set :repo_url, "git@github.com:idengager/houdini.git"
set :rails_env, 'production'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/houdini/houdini"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/database.yml", ".env", "config/settings.yml"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "node_modules"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :npm_flags, '--silent --no-progress'
set :npm_env_variables, {'RAILS_ENV': 'production'}

after 'npm:install', 'npm:build'

namespace :npm do
  task :build do
    on roles fetch(:npm_roles) do
      within fetch(:npm_target_path, release_path) do
        with fetch(:npm_env_variables, {}) do
          # fix uglifyjs-webpack-plugin
          execute :npm, 'install --silent --no-progress --save uglifyjs-webpack-plugin@1.2.5'

          execute :npm, 'run build', fetch(:npm_flags)
        end
      end
    end
  end
end

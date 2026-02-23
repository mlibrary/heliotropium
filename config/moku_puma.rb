require "yaml"
infrastructure = YAML.load_file(File.join(File.dirname(__FILE__), "../infrastructure.yml"))

environment "production"
threads 1, 4

# Bind to the private network address
# Use tcp as the http server (apache) is on a different host.
bind infrastructure["bind"]

base_dir = infrastructure["base_dir"]
pidfile File.join(base_dir, "current", "log", "puma.pid")

# Redirect STDOUT and STDERR to files specified. The 3rd parameter
# ("append") specifies whether the output is appended, the default is
# "false".
#
stdout_redirect(
  File.join(base_dir, "current", "log", "puma.stdout.log"),
  File.join(base_dir, "current", "log", "puma.stderr.log"),
  true
)

on_restart do
# Code to run before doing a restart. This code should
# close log files, database connections, etc.
end

workers 4
worker_timeout 120
on_worker_boot do
  # Code to run when a worker boots to setup the process before booting
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect!
end

preload_app!


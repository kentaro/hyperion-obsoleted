if (ENV[RAILS_ENV] == 'development')
  require 'rack-livereload'
  use Rack::LiveReload
end

require ::File.expand_path('../config/environment',  __FILE__)
run Hyperion::Application

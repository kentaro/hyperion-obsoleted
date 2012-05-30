require 'rack-livereload'
use Rack::LiveReload

require ::File.expand_path('../config/environment',  __FILE__)
run Hyperion::Application

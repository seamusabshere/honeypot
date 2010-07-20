require 'honeypot'
require 'rails'

module Honeypot
  class Railtie < Rails::Railtie
    # more or less, this puts us after the rails helper stuff (ActionDispatch::RemoteIp) but before most custom middleware
    config.app_middleware.insert_after '::Rack::MethodOverride', '::Honeypot::TrueRemoteIp'
  end
end

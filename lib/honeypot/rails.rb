require 'honeypot'

::Rails.configuration.middleware.insert_after '::Rack::MethodOverride', '::Honeypot::BestGuessRouteableRemoteIp'

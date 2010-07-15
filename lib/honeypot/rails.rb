require 'honeypot'

raise "rails 2.3 support isn't tested"

::Rails.configuration.middleware.insert_after '::Rack::MethodOverride', '::Honeypot::BestGuessRouteableRemoteIp'

require 'honeypot'

if defined?(::Rails.configuration) && ::Rails.configuration.respond_to?(:middleware)
  ::Rails.configuration.middleware.insert_after 'ActionController::Failsafe', ::Honeypot::Rack
end

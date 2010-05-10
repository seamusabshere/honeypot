require 'honeypot'
require 'rails'

module Honeypot
  class Railtie < Rails::Railtie
    initializer "honeypot.configure_rails_initialization" do |app|
      app.middleware.use Honeypot::Rack
    end
  end
end

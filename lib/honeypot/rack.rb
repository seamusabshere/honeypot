# inspired by hoptoad_notifier
# http://charlesmaxwood.com/sessions-in-rack-and-rails-metal/
module Honeypot
  # Middleware for Rack applications. Remote hosts will be tied together with remote requests.
  class Rack
    def initialize(app)
      @app = app
    end

    def call(env)
      session = env['rack.session']
      remote_ip = IPAddr.new env['action_dispatch.remote_ip'].to_s
      session['honeypot.last_known_remote_ip'] = remote_ip.to_s if remote_ip.public?
      @app.call env
    end
  end
end

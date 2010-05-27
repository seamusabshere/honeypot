# inspired by hoptoad_notifier
# http://charlesmaxwood.com/sessions-in-rack-and-rails-metal/
module Honeypot
  # Middleware for Rack applications. Remote hosts will be tied together with remote requests.
  class Rack
    def initialize(app)
      @app = app
    end

    def call(env)
      if session = env['rack.session'] and raw_remote_ip = env['action_dispatch.remote_ip']
        remote_ip = IPAddr.new raw_remote_ip.to_s 
        session['honeypot.last_known_remote_ip'] = remote_ip.to_s if remote_ip.public?
      end
      @app.call env
    end
  end
end

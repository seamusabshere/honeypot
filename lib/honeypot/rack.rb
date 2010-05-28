# inspired by hoptoad_notifier
# http://charlesmaxwood.com/sessions-in-rack-and-rails-metal/
module Honeypot
  # Middleware for Rack applications. Remote hosts will be tied together with remote requests.
  class Rack
    def initialize(app)
      @app = app
    end

    def call(env)
      raw_remote_ip = if env.has_key?('action_dispatch.remote_ip') # rails 3
        env['action_dispatch.remote_ip']
      elsif env.has_key?('action_controller.rescue.request') # rails 2
        env['action_controller.rescue.request'].remote_ip
      end
      if raw_remote_ip and session = env['rack.session']
        remote_ip = IPAddr.new raw_remote_ip.to_s
        session['honeypot.last_known_remote_ip'] = remote_ip.to_s if remote_ip.public?
      end
      @app.call env
    end
  end
end

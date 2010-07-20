# inspired by hoptoad_notifier
# http://charlesmaxwood.com/sessions-in-rack-and-rails-metal/
module Honeypot
  # Middleware for Rack applications. Remote hosts will be tied together with remote requests.
  class TrueRemoteIp
    def initialize(app)
      @app = app
    end

    def call(env)
      ip = ::Honeypot.true_remote_ip _possible_remote_ips(env)

      # For the next request, in case the next time we see this session the remote ip is obscured
      # (for example, that happens if you're on engineyard and the request comes in over SSL)
      if ip and env.has_key? 'rack.session'
        env['rack.session']['honeypot.true_remote_ip'] = ip
      end
      
      # For use by other middleware or the app itself
      env['honeypot.true_remote_ip'] = ip

      @app.call env
    end

    def _possible_remote_ips(env)
      candidates = Array.new
      # nicely provided by Rails 3
      if env['action_dispatch.remote_ip']
        candidates.push env['action_dispatch.remote_ip']
      end
      # saved by honeypot between requests
      if env['rack.session']
        candidates.push env['rack.session']['honeypot.true_remote_ip']
      end
      candidates
    end
  end
end

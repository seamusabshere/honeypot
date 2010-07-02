# inspired by hoptoad_notifier
# http://charlesmaxwood.com/sessions-in-rack-and-rails-metal/
module Honeypot
  # Middleware for Rack applications. Remote hosts will be tied together with remote requests.
  class Rack
    def initialize(app)
      @app = app
    end

    def call(env)
      remote_ip = _most_likely_remote_ip env

      # For the next request, in case the next time we see this session the remote ip is obscured
      # (for example, that happens if you're on engineyard and the request comes in over SSL)
      if env.has_key? 'rack.session' and remote_ip.routeable?
        env['rack.session']['honeypot.last_known_routeable_remote_ip'] = remote_ip.to_s
      end
      
      # For use by other middleware or the app itself
      env['honeypot.remote_ip'] = remote_ip.to_s

      @app.call env
    end

    def _most_likely_remote_ip(env)
      candidates = _collect_possible_remote_ips env
      candidates.detect { |remote_ip| remote_ip.routeable? } || candidates.first
    end

    def _collect_possible_remote_ips(env)
      candidates = Array.new
      # rails 3
      if env.has_key? 'action_dispatch.remote_ip'
        candidates.push env['action_dispatch.remote_ip']
      end
      # rails 2
      if env.has_key? 'action_controller.rescue.request'
        candidates.push env['action_controller.rescue.request']
      end
      # saved by honeypot between requests
      if env.has_key? 'rack.session'
        candidates.push env['rack.session']['honeypot.last_known_routeable_remote_ip']
      end
      candidates.map! { |raw_ip_address| IPAddr.new raw_ip_address.to_s }
      candidates
    end
  end
end

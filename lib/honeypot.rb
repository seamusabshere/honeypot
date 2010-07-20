require 'ipaddr'
require 'set'
require 'active_support'
require 'active_support/version'
%w{
  active_support/core_ext/object/blank
}.each do |active_support_3_requirement|
  require active_support_3_requirement
end if ActiveSupport::VERSION::MAJOR == 3
require 'active_record'
require 'fast_timestamp'
require 'honeypot/remote_request'
require 'honeypot/remote_host'

module Honeypot
  def self.included(base)
    base.class_eval do
      has_many :remote_requests, :as => :requestable, :dependent => :destroy
      has_many :remote_hosts, :through => :remote_requests, :uniq => true
    end
  end
  
  # Returns a String of the first remote ip, or nil if it doesn't find any.
  def self.true_remote_ip(ips)
    hit = ips.detect { |ip| routeable_ip? ip }
    return unless hit
    hit.to_s
  end
  
  UNROUTEABLE_CIDRS = [
    ::IPAddr.new('127.0.0.1/32'),
    ::IPAddr.new('10.0.0.0/8'),
    ::IPAddr.new('172.16.0.0/12'),
    ::IPAddr.new('192.168.0.0/16')
  ]
  
  def self.routeable_ip?(ip)
    ip_addr = ::IPAddr.new ip.to_s
    ip_addr.ipv4? and UNROUTEABLE_CIDRS.none? { |cidr| cidr.include? ip_addr }
  rescue ArgumentError
    false
  end
  
  # The Rack middleware isn't enabled, so we have to do it here.
  # On other requests you'll have to manually save session['honeypot.true_remote_ip']
  def log_rails_2_request(request, session)
    if ip = ::Honeypot.true_remote_ip([request.remote_ip, session['honeypot.true_remote_ip']])
      session['honeypot.true_remote_ip'] = ip
      log_remote_request ip, request.url, request.referer
    end
  end
  
  # For use in Rails 3 and other Rack apps.  
  def log_rack_env(env)
    request = ::Rack::Request.new env
    if env['honeypot.true_remote_ip'].present?
      log_remote_request env['honeypot.true_remote_ip'], request.url, request.referer
    end
  end
  
  def log_remote_request(ip, url, referer)
    remote_host = RemoteHost.find_or_create_by_ip_address ip
    remote_request = remote_requests.find_or_create_by_remote_host_id remote_host.id
    remote_request.last_http_referer = referer
    remote_request.last_request_uri = url
    remote_request.increment :hits
    remote_request.save!
    true
  end
  
  def related_requestables(seen_remote_host_ids = Array.new)
    set = Set.new
    conditions = seen_remote_host_ids.present? ? [ "remote_hosts.id NOT IN (?)", seen_remote_host_ids ] : nil
    remote_hosts.where(conditions).find_in_batches do |batch|
      batch.each do |remote_host|
        seen_remote_host_ids << remote_host.id
        remote_host.remote_requests.all(:include => :requestable).each do |remote_request|
          set << remote_request.requestable
        end
      end
    end
    if respond_to?(:actor) and actor != self
      set += actor.related_requestables(seen_remote_host_ids)
    end
    set.delete self
    set
  end
end

if defined? ::Rails::Railtie and ActiveSupport::VERSION::MAJOR > 2
  require 'honeypot/true_remote_ip'
  require 'honeypot/railtie'
end

require 'ipaddr'
require 'set'
require 'active_support'
require 'active_record'
require 'honeypot/ipaddr_ext'
require 'honeypot/rack'

require 'honeypot/railtie' if defined?(Rails::Railtie)

module Honeypot
  def self.included(base)
    base.class_eval do
      has_many :remote_requests, :as => :requestable, :dependent => :destroy
      has_many :remote_hosts, :through => :remote_requests, :uniq => true
    end
  end
  
  def log_remote_request(session, request)
    return unless session['honeypot.last_known_remote_ip'].present?
    remote_host = RemoteHost.find_or_create_by_ip_address session['honeypot.last_known_remote_ip']
    remote_request = remote_requests.find_or_create_by_remote_host_id remote_host.id
    remote_request.last_http_referer = request.referer if request.referer.present?
    remote_request.last_request_uri = request.request_uri if request.request_uri.present?
    remote_request.increment :hits
    remote_request.save!
    true
  end
  
  def related_requestables(seen_remote_host_ids = [])
    set = Set.new
    conditions = seen_remote_host_ids.present? ? [ "remote_hosts.id NOT IN (?)", seen_remote_host_ids ] : nil
    remote_hosts.scoped(:conditions => conditions).find_in_batches do |batch|
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

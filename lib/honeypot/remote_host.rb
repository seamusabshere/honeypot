class RemoteHost < ActiveRecord::Base
  has_many :remote_requests, :dependent => :destroy

  include FastTimestamp

  def lookup_hostname
    result = Resolv.getname ip_address
    if result.present?
      update_attribute :hostname, result
      untimestamp! :failed_to_lookup_hostname
    else
      timestamp! :failed_to_lookup_hostname
    end
  rescue # Resolv::ResolvError
    timestamp! :failed_to_lookup_hostname
  end
  
  def geolocate
    location = Geokit::Geocoders::MultiGeocoder.geocode ip_address
    
    # take what we can get
    if location.success
      self.latitude = location.lat if location.lat.present?
      self.longitude = location.lng if location.lng.present?
      self.country_code = location.country_code if location.country_code.present?
      # state -> state_name
      self.state_name = location.state if location.state.present?
      self.city = location.city if location.city.present?
      save!
    end
    
    # but only call it a success if we get latitude
    # this way if we don't, it will check again in 5 days
    if location.success and location.latitude.present?
      untimestamp! :failed_to_geolocate
    else
      timestamp! :failed_to_geolocate
    end
  rescue
    timestamp! :failed_to_geolocate
  end

  def delayed_lookup_hostname
    if (rand(20) == 1 or hostname.blank?) and (
         !timestamped?(:failed_to_lookup_hostname) or
         timestamp_for(:failed_to_lookup_hostname) < 5.days.ago
       )
      defined?(Delayed::Job) ? send_later(:lookup_hostname) : lookup_hostname
    end
    true
  end

  def delayed_geolocate
    if (rand(20) == 1 or latitude.blank?) and (
         !timestamped?(:failed_to_geolocate) or
         timestamp_for(:failed_to_geolocate) < 5.days.ago
       )
      defined?(Delayed::Job) ? send_later(:geolocate) : geolocate
    end
    true
  end

  after_save :delayed_lookup_hostname
  after_save :delayed_geolocate
end

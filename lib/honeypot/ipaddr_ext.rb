# http://codesnippets.joyent.com/posts/show/7546
class IPAddr
  UNROUTEABLE_RANGES = [
    IPAddr.new('127.0.0.1/32'),
    IPAddr.new('10.0.0.0/8'),
    IPAddr.new('172.16.0.0/12'),
    IPAddr.new('192.168.0.0/16')
  ]
  
  def unrouteable?
    return false unless self.ipv4?
    UNROUTEABLE_RANGES.any? { |ipr| ipr.include? self }
  end

  def routeable?
    !unrouteable?
  end
end

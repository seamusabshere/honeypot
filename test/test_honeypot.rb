require 'helper'

class TestHoneypot < Test::Unit::TestCase
  def test_ip_is_recognized_as_public_or_private
    assert IPAddr.new('192.168.1.1').private?
    assert IPAddr.new('10.0.0.2').private?
    assert IPAddr.new('172.16.0.2').private?
    assert IPAddr.new('88.122.122.122').public?
  end
end

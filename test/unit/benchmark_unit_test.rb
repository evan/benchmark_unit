
$LOAD_PATH << File.dirname(__FILE__) + "/../../lib"

require 'benchmark/unit'
require 'test/unit'

class BenchmarkUnitTest < Test::Unit::TestCase
  
  def test_faster
    assert_faster do
      sleep(1)
    end 
  end

  def test_slower
    assert_slower do
      # Do nothing
    end   
  end

  def test_wrapped_faster
  
  end

  def test_wrapped_slower
  
  end

  
end

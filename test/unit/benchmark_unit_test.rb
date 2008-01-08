
$LOAD_PATH << File.dirname(__FILE__) + "/../../lib"

# Test both requires
require 'benchmark/unit'
require 'benchmark_unit'

STDERR.puts "RubySeconds.size is #{Benchmark::RubySeconds.size}" if ENV['DEBUG']

class BenchmarkUnitTest < Test::Unit::TestCase
  
  def test_faster
    assert_faster(3) do
      "string" * 100
    end
    
    assert_raises Test::Unit::AssertionFailedError do
      assert_faster do
        # Do nothing
      end 
    end
  end

  def test_slower
    assert_slower(1.1) do
      "string" * 30000000
    end
    
    assert_raises Test::Unit::AssertionFailedError do
      assert_slower do
        "string" * 3000
      end   
    end
  end
  
  #  def test_sleep
  #    # Loops forever due to thread scheduling issues
  #    assert_slower(2) do
  #      sleep(3 * Benchmark::RubySeconds.size)
  #    end    
  #  end
  
  def test_failed_assertion_has_clean_backtrace
    begin
      assert_slower(3) do
        "fast"
      end
    rescue Test::Unit::AssertionFailedError => e
      assert e.backtrace.to_s !~ /compare_benchmark|benchmark.rb/
    end
  end

  def test_exception_has_clean_backtrace
    begin
      assert_faster(3) do
        raise "o crap"
      end
    rescue RuntimeError => e
      assert e.backtrace.to_s !~ /compare_benchmark|benchmark.rb/
    end
  end
  
end


$LOAD_PATH << File.dirname(__FILE__) + "/../../lib"

require 'benchmark/unit'
require 'test/unit'

# STDERR.puts "RubySeconds.size is #{Benchmark::RubySeconds.size}"

class BenchmarkUnitTest < Test::Unit::TestCase
  
  def test_faster
    assert_faster do
      # Do nothing
    end 
    assert_faster(3) do
      "string" * 100
    end
  end

  def test_slower
    assert_slower do
      "string" * 100
    end   
    assert_slower(1.1) do
      "string" * 30000000
    end
  end 
  
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

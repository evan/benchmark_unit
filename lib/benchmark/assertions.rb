
module Benchmark
  module Unit
    module Assertions
      
      def assert_faster(target = 1/0.0, &block)
        _wrap_assertion do
          compare_benchmark(target, :faster, &block)
        end
      end
      
      def assert_slower(target = 0, &block) # Infinity
        _wrap_assertion do
          compare_benchmark(target, :slower, &block)
        end
      end      
      
      private
      
      def compare_benchmark(target, operator)
        time, multiplier = 0, 1

        while (time < 0.01) do
          # STDERR.puts "Multiplier is #{multiplier}"
          time = Benchmark::Unit.measure do 
            multiplier.times {yield}
          end
          # STDERR.puts "Time was #{time}"
          multiplier *= 10
        end
        
        multiplier /= 10
        
        iterations = (CLOCK_TARGET / time).to_i * multiplier
        iterations = 1 if iterations < 1
        
        total = Benchmark::Unit.measure do 
          iterations.times do
            yield
          end
        end
        
        time = total / iterations
        message = "Time #{time.inspect} expected to be #{operator} than #{target.inspect}."
        
        if operator == :faster        
          assert((time < target), message)
        elsif operator == :slower
          assert((time > target), message)
        end
      end
      
    end
  end
end

require 'test/unit/error'

module Test
  module Unit
    class TestCase
      include Benchmark::Unit::Assertions
    end
  end
end

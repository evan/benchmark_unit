
module Benchmark
  module Unit
    module Assertions
      
      def assert_faster(target = 1/0.0, &block)
        clean_backtrace do
          compare_benchmark(target, :faster, &block)
        end
      end
      
      def assert_slower(target = 0, &block) # Infinity
        clean_backtrace do
          compare_benchmark(target, :slower, &block)
        end
      end      
      
      private
      
      def compare_benchmark(target, operator)
        raise unless [:faster, :slower].include? operator
      
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
        
        iterations = (Benchmark::Unit::CLOCK_TARGET / time).to_i * multiplier
        iterations = 1 if iterations < 1
        
        total = Benchmark::Unit.measure do 
          iterations.times do
            yield
          end
        end
        
        time = total / iterations
        message = "<#{time.inspect} RubySeconds> is not #{operator} than #{target.inspect} RubySeconds."
        
        assert_block message do 
          if operator == :faster        
            time < target
          elsif operator == :slower
            time > target
          end
        end

      end

      def clean_backtrace(&block)
        # Modified from Rails' version
        begin
          yield
        rescue Object => error
          library_path = Regexp.new(
            File.expand_path("#{File.dirname(__FILE__)}/(assertions|unit)") + 
            '|benchmark.rb.*measure'
          )
          error.backtrace.reject! { |line| File.expand_path(line) =~ library_path }
          raise
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

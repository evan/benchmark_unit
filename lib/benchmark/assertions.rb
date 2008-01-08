
require 'test/unit'

module Benchmark #:nodoc:
  module Unit
    module Assertions
      
      # Assert that the average execution time of the block is faster than the target number of RubySeconds (i.e., takes less time). Default target is 0 (everything fails).
      def assert_faster(target = 0, &block)
        clean_backtrace do
          compare_benchmark(target, :faster, &block)
        end
      end
      
      # Assert that the average execution time of the block is slower than the target number of RubySeconds (i.e., takes more time). Default target is Infinity (everything fails).
      def assert_slower(target = 1/0.0, &block) # Infinity
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

      # Strip our library files from the assertion backtrace.
      def clean_backtrace(&block) #:nodoc:
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

#:stopdoc:

class Test::Unit::TestCase
  include Benchmark::Unit::Assertions
end

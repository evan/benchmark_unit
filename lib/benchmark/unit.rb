
require 'benchmark'
require 'benchmark/float'

module Benchmark
  module Unit

    CLOCK_TARGET = 2
  
    def measure
      RubySeconds.new(
        Benchmark.measure do
          yield
        end.total
      )
    end
  
    class RubySeconds < Float
    
      def initialize(value)
        @value = value.to_f / RubySeconds.size
      end
    
      class << self
      
        # Measure the "standard" Ruby unit of time.
        def measure
          Benchmark.measure do
            4.times { quanta }
          end.total / 4.0
        end
        
        # Approach a stable unit size and memoize it.
        def size
          @size ||= begin
            last, size = 0, measure
            while (size < last or (size - last) / size > 0.005) do
              last, size = size, measure
            end
            last
          end
        end
        
        private 
        
        # Perform some common Ruby operations.
        def quanta
          # Allocate things
          array = [:symbol, "a = 3 if true", 2, Math::PI**2, "large string"*30] * 100
          # Re-assign
          array.flatten!
          # Process things with a closure
          array.each_with_index do |item, index|
            begin
              case index % 4
                when 0: item * 20000
                when 1: item / Math::PI / 2.0
                when 2: "#{item} #{item} #{item}"
                when 3: eval(item) if item =~ /true/
              end
            rescue Object => e
            end
          end
          # Dispatch some methods
          recurse(20)
        end
        
        def recurse(i)
          recurse(i - 1) if i > 0
        end
        
      end
    end
  
    module Assertions
      
      def assert_faster(target = 0)
        clean_backtrace do
          compare_benchmark(target, :faster)
        end
      end
      
      def assert_slower(target = 1/0.0) # Infinity
        clean_backtrace do
          compare_benchmark(target, :slower)
        end
      end      
      
      private
      
      def compare_benchmark(target, operator)
        time_for_one = Benchmark::Unit.measure do 
          yield
        end
        
        iterations = CLOCK_TARGET / time_for_one
        iterations = 1 if iterations < 1
        
        total = Benchmark::Unit.measure do 
          iterations.times do
            yield
          end
        end
        
        time = total / iterations          
        message = "Time #{time} RubySeconds expected to be #{operator} than #{target} RubySeconds."
        
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


module Benchmark
  class RubySeconds
  
    PRECISION = 0.05
      
    attr_accessor :value
      
    # Create a RubySeconds object from wall clock seconds.
    def initialize(seconds)
      @value = seconds.to_f / RubySeconds.size
    end
    
    # Delegate to the float. Inheriting from Float doesn't work well.
    def method_missing(*args)
      @value.send(*args)
    end
    
    def to_s
      @value.to_s
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
          while (size < last or (size - last) / size > PRECISION) do
            last, size = size, measure
          end
          last
        end
      end
      
      private 
      
      # Perform some common Ruby operations so we can measure how long they take.
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
end

module Benchmark #:nodoc:

=begin rdoc
RubySeconds are a machine-independent time measurement derived from benchmarking your hardware on some typical Ruby code. A RubySecond should be consistent enough for testing purposes across most architectures--hopefully within a 1/2 order of magnitude.

To see what your machine's RubySecond is in clock-seconds, call Benchmark::RubySeconds.size. 
=end
  class RubySeconds
  
    PRECISION = 0.05
      
    attr_reader :value
      
    # Create a RubySeconds object from clock-seconds.
    def initialize(seconds)
      @value = seconds.to_f / RubySeconds.size
    end
    
    # Delegate to the float. Inheriting from Float doesn't work well.
    def method_missing(*args) #:nodoc:
      @value.send(*args)
    end
    
    def to_s #:nodoc:
      @value.to_s
    end
  
    class << self
    
      # Return the size of a single RubySecond in clock-seconds for this machine.
      def size
        @size ||= begin
          last, size = 0, measure
          # Gradually approach a stable unit size, up to PRECISION %
          while (size < last or (size - last) / size > PRECISION) do
            last, size = size, measure
          end
          last
        end
      end
      
      protected

      # Measure the "standard" Ruby unit of time on this machine.
      def measure 
        Benchmark.measure do
          4.times { quanta }
        end.total / 4.0
      end      
      
      # Perform some typical Ruby operations.
      def quanta
        # Allocate things
        array = [[:symbol, "a = 3 if true", 2, Math::PI**2, "large string"*30]] * 100
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
      
      def recurse(i) #:nodoc:
        recurse(i - 1) if i > 0
      end
      
    end
  end
end
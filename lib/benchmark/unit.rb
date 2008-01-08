
require 'benchmark'

require 'rubygems'
require 'ruby-debug'; Debugger.start

require 'benchmark/ruby_seconds'
require 'benchmark/assertions'
require 'benchmark/float'

module Benchmark
  module Unit

    CLOCK_TARGET = 2
    
    def self.measure
      RubySeconds.new(
        Benchmark.measure do
          yield
        end.total
      )
    end
  
  end
end




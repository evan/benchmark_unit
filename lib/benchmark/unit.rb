
require 'benchmark'

if ENV['DEBUG']
  require 'rubygems'
  require 'ruby-debug'; Debugger.start
end

require 'benchmark/ruby_seconds'
require 'benchmark/assertions'
require 'benchmark/float'

module Benchmark #:nodoc:
  module Unit

    CLOCK_TARGET = 2
    
    # Measure a single run of a block in RubySeconds.
    def self.measure
      RubySeconds.new(
        Benchmark.measure do
          yield
        end.total
      )
    end
  
  end
end




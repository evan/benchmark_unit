
class Float
  # Return <tt>self</tt> in RubySeconds for this machine.
  def to_ruby_seconds
    Benchmark::RubySeconds.new(self)
  end  
end
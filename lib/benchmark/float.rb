
class Float
  def to_ruby_seconds
    Benchmark::RubySeconds.new(self)
  end  
end
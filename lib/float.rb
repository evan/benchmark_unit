
class Float
  def to_ruby_seconds
    Benchmark::Unit::RubySeconds.new(self)
  end  
end
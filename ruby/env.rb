class Env
  attr_accessor :data
  def initialize(outer=nil, data={})
    @outer = outer
    @data = data
  end

  def set(key, value)
    @data[key] = value
  end

  def find(key)
    if @data.key? key
      return self
    end
    if @outer
      return @outer.find key
    end
    return nil
  end

  def get(key)
    env = find(key)
    raise "'#{key.to_s}' not found" unless env
    return env.data[key]
  end
end
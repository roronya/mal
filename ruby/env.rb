class Env
  attr_accessor :data
  def initialize(outer=nil, binds=[], exprs=[])
    @outer = outer
    @data = {}
    binds.each_index do |i|
      if binds[i] == :&
        set(binds[i+1], exprs.drop(i))
        break
      end
      set(binds[i], exprs[i])
    end
  end

  def set(key, value)
    @data[key] = value
    $logger.debug("env:Env:@data.keys:in_set_method #=> #{@data.keys}")
    return value
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
    $logger.debug("env:Env:env.data[key]:in_get_method #=> #{env.data[key]}")
    return env.data[key]
  end
end
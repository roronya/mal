class List < Array
end

class Vector < Array
end

class Function < Proc
  attr_accessor :ast, :params, :env, :is_macro
  def initialize(ast, params, env, is_macro=false, &block)
    super()
    @ast = ast
    @params = params
    @env = env
    @is_macro = is_macro
  end

  def get_env(args)
    return Env.new(@env, @params, args)
  end
end

class Atom
  attr_accessor :meta
  attr_accessor :val
  def initialize(val)
    @val = val
  end
end

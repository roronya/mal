class List < Array
end

class Vector < Array
end

class Function < Proc
  attr_accessor :ast, :params, :env
  def initialize(ast, params, env, &block)
    super()
    @ast = ast
    @params = params
    @env = env
  end

  def get_env(args)
    return Env.new(@env, @params, args)
  end
end

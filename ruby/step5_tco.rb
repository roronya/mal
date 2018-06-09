require 'readline'
require_relative 'printer'
require_relative 'reader'
require_relative 'env'
require_relative 'core'
require 'logger'
$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

def READ(str)
  return read_str(str)
end

def EVAL(ast, env)
  loop do
    $logger.debug("EVAL:ast #=> #{ast}")
    if not ast.is_a? List
      return eval_ast(ast, env)
    end
    return ast if ast.empty?
    a0, a1, a2, a3 = ast
    case a0
      when :def!
        return env.set(a1, EVAL(a2, env))
      when :'let*'
        # (let* (a (+ 1 2) b (+ a 3)) b) #=> 6
        let_env = Env.new env
        a1.each_slice(2).each do |key, value|
          let_env.set(key, EVAL(value, let_env))
        end
        env = let_env
        ast = a2
      when :do
        eval_ast(ast[1...-1], env)
        ast = ast.last
      when :if
        if EVAL(a1, env)
          ast = a2
        else
          return nil unless a3
          ast = a3
        end
      when :'fn*'
        return Function.new a2, a1, env do |*args|
          EVAL(a2, Env.new(env, a1, List.new(args)))
        end
      else
        el = eval_ast(ast, env)
        f = el[0]
        if Function === f
          ast = f.ast
          env = f.get_env(el.drop(1))
        else
          return f[*el.drop(1)]
        end
    end
  end
end

def eval_ast(ast, env)
  $logger.debug("eval_ast:ast.class #=> #{ast.class}")
  return case ast
           when Symbol
             $logger.debug("eval_ast:env.get(ast) #=> #{env.get(ast)}")
             env.get(ast)
           when List
             List.new ast.map {|e| EVAL(e, env)}
           when Vector
             Vector.new ast.map {|e| EVAL(e, env)}
           when Hash
             ast.to_a.map {|k, v| [k, EVAL(v, env)]}.to_h
           else
             ast
         end
end

def PRINT(exp)
  return pr_str(exp)
end

repl_env = Env.new
$core_ns.each {|k, v| repl_env.set(k, v)}
REP = ->(str) {PRINT(EVAL(READ(str), repl_env))}
REP['(def! not (fn* (a) (if a false true)))']
$logger.debug("$repl_env.data #=> #{repl_env.data}")

while line = Readline.readline('user> ')
  begin
    puts REP[line]
  rescue => e
    puts e
    puts "\t#{e.backtrace.join("\n\t")}"
  end
end


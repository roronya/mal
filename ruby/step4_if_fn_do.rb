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
  $logger.debug("EVAL:ast #=> #{ast}")
  if not ast.is_a? List
    return eval_ast(ast, env)
  end
  return ast if ast.empty?
  a0, a1, a2, a3 = ast
  case a0
    when :def!
      env.set(a1, EVAL(a2, env))
    when :'let*'
      let_env = Env.new env
      a1.each_slice(2).each do |key, value|
        let_env.set(key, EVAL(value, let_env))
      end
      EVAL(a2, let_env)
    when :do
      return eval_ast(ast.drop(1), env).last
    when :if
      if EVAL(a1, env)
        return EVAL(a2, env)
      else
        if a3
          return EVAL(a3, env)
        end
        return nil
      end
    when :'fn*'
      # (fn* [a] (print a)) #=> ->(a){print a}
      # ((fn* [a] (print a)) "hoge") #=> ->(a){print a}["hoge"]
      # ↑のように呼ばれたときにEVALする関数を作るイメージ
      # このタイミングではEVALは走らない。呼び出されたときにEVALする関数を作る。
      return ->(*args) {EVAL(a2, Env.new(env, a1, List.new(args)))}
    else
      ast = eval_ast(ast, env)
      ast[0][*ast.drop(1)]
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
$core_ns.each{|k,v| repl_env.set(k,v)}
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


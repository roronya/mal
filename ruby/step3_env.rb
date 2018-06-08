require 'readline'
require_relative 'printer'
require_relative 'reader'
require_relative 'env'
require 'logger'
$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

$repl_env = Env.new
$repl_env.set(:+, ->(a, b) {a+b})
$repl_env.set(:-, ->(a, b) {a-b})
$repl_env.set(:*, ->(a, b) {a*b})
$repl_env.set(:/, ->(a, b) {a/b})
$logger.debug("$repl_env.data #=> #{$repl_env.data}")

def READ(str)
  return read_str(str)
end

def EVAL(ast, env)
  $logger.debug("EVAL:ast #=> #{ast}")
  if not ast.is_a? List
    return eval_ast(ast, env)
  end
  return ast if ast.empty?
  case ast[0]
    when :def!
      if ast.size != 3
        raise 'expected ast with size 3'
      end
      env.set(ast[1], EVAL(ast[2], env))
    when :'let*'
      if ast.size != 3
        raise 'expected ast with size 3'
      end
      let_env = Env.new env
      ast[1].each_slice(2).each do |key, value|
        let_env.set(key, EVAL(value, let_env))
      end
      EVAL(ast[2], let_env)
    else
      ast = eval_ast(ast, env)
      ast[0][*ast.drop(1)]
  end
end

def PRINT(exp)
  return pr_str(exp)
end

def REP(str)
  return PRINT(EVAL(READ(str), $repl_env))
rescue => e
  puts e
end

def eval_ast(ast, env)
  return case ast
           when Symbol
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

while line = Readline.readline('user> ')
  puts REP(line)
end


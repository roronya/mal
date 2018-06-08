require 'readline'
require_relative 'printer'
require_relative 'reader'
require 'logger'
$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

$repl_env = {'+': ->(a, b) {a+b},
             '-': ->(a, b) {a-b},
             '*': ->(a, b) {a*b},
             '/': ->(a, b) {a/b}}

def READ(str)
  return read_str(str)
end

def EVAL(ast, env)
  $logger.debug("EVAL:ast #=> #{ast}")
  if not ast.is_a? List
    return eval_ast(ast, env)
  end
  return ast if ast.empty?
  ast = eval_ast(ast, env)
  ast[0][*ast.drop(1)]
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
             raise "'#{ast.to_s}' not found" unless env.key? ast
             env[ast]
           when List
             List.new ast.map {|e| EVAL(e, env)}
           when Vector
             Vector.new ast.map {|e| EVAL(e, env)}
           when Hash
             ast.to_a.map{|k,v| [k, EVAL(v, env)]}.to_h
           else
             ast
         end
end

while line = Readline.readline('user> ')
  puts REP(line)
end


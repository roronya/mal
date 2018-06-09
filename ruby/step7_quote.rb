require 'readline'
require_relative 'printer'
require_relative 'reader'
require_relative 'env'
require_relative 'core'
require 'logger'
$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

def pair?(list)
  return (List === list || Vector === list) && list.size > 0
end

def quasiquote(ast)
  if not pair?(ast)
    return List.new [:quote, ast]
  elsif ast[0] == :unquote
    return ast[1]
  elsif pair?(ast[0]) && ast[0][0] == :'splice-unquote'
    return List.new [:concat, ast[0][1], quasiquote(ast.drop(1))]
  else
    return List.new [:cons, quasiquote(ast[0]), quasiquote(ast.drop(1))]
  end
end

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
      when :quote
        return a1
      when :quasiquote
        # (def! a (quote (+ 1 2)))
        # (quosiquote (+ 1 2 (unquote a))) #=> (+ 1 2 3)
        # quosiquoteの中ではunquoteが使えて、unquoteの引数に渡されたquoteされた部分はEVALされて、
        # quosiquote自信の引数はもう一度quoteされるっぽい。
        ast = quasiquote(a1)
        $logger.debug("EVAL:ast:after_quosiquote_function #=> #{ast}")
      else
        el = eval_ast(ast, env)
        $logger.debug("EVAL:el #=> #{el}")
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
REP = ->(str) {PRINT(EVAL(READ(str), repl_env))}
RE = ->(str) {EVAL(READ(str), repl_env)}

$core_ns.each {|k, v| repl_env.set(k, v)}
repl_env.set(:eval, ->(ast) {EVAL(ast, repl_env)})
repl_env.set(:'*ARGV*', List.new(ARGV.slice(1, ARGV.size) || []))

RE['(def! not (fn* (a) (if a false true)))']
RE['(def! load-file (fn* (f) (eval (read-string (str "(do " (slurp f) ")")))))']
$logger.debug("$repl_env.data #=> #{repl_env.data}")

if ARGV.size > 0
  RE["(load-file \"#{ARGV[0]}\")"]
  exit 0
end

while line = Readline.readline('user> ')
  begin
    next if line == ''
    puts REP[line]
  rescue => e
    puts e
    puts "\t#{e.backtrace.join("\n\t")}"
  end
end


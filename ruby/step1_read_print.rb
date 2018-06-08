require 'readline'
require_relative 'printer'
require_relative 'reader'

def READ(str)
  return read_str(str)
rescue => e
  puts e
end

def EVAL(ast, env)
  return ast
end

def PRINT(exp)
  return pr_str(exp)
end

def REP(str)
  return PRINT(EVAL(READ(str), {}))
end

while line = Readline.readline('user> ')
  puts REP(line)
end

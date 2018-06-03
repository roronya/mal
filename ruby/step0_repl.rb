require "readline"

def READ(str)
  return str
end

def EVAL(ast, env)
  return ast
end

def PRINT(exp)
  return exp
end

def REP(str)
  return PRINT(EVAL(READ(str), {}))
end

while line = Readline.readline('user> ')
   puts REP(line)
end

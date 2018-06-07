class Reader
  def initialize(tokens)
    @tokens = tokens
    @position = 0
  end

  def next
    @position += 1
    @tokens[@position - 1]
  end

  def peek
    @tokens[@position]
  end
end

def tokenizer(str)
  regex = /[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}()'"`,;]*)/
  str.split(regex).reject {|token| token.empty?}.push('')
end

def read_str(str)
  tokens = tokenizer(str)
  rdr = Reader.new(tokens)
  read_form(rdr)
end

def read_form(rdr)
  case rdr.peek
    when '(' then
      read_list(rdr)
    else
      read_atom(rdr)
  end
end

def read_list(rdr)
  ast = []
  token = rdr.next
  if token != '('
    raise "expected '(', got #{token}"
  end
  while (token = rdr.peek) != ')'
    if token == ''
      raise "expected ')', got #{token}"
    end
    ast.push(read_form(rdr))
  end
  rdr.next
  return ast
end

def read_atom(rdr)
  token = rdr.next
  if i = /\d+/.match(token)
    i[0].to_i
  else
    token.to_s
  end
end

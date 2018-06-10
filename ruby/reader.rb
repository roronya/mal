require_relative 'types'

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
  str.split(regex).reject {|token| token.empty? || token[0] == ';'}.push('')
end

def read_str(str)
  tokens = tokenizer(str)
  $logger.debug("reader:read_str:tokens #=> #{tokens}")
  return nil if tokens.size == 1
  rdr = Reader.new(tokens)
  ast = read_form(rdr)
  return ast
end

def read_form(rdr)
  return case rdr.peek
           when '(' then
             read_list(rdr, List)
           when ')' then
             raise 'unexpected \')\''
           when '[' then
             read_list(rdr, Vector, start='[', last=']')
           when ']' then
             raise 'unexpected \']\''
           when '{' then
             Hash[read_list(rdr, List, start='{', last='}').each_slice(2).to_a]
           when '}' then
             raise 'unexpected \'}\''
           when '\'' then
             rdr.next
             List.new [:quote, read_form(rdr)]
           when '`' then
             rdr.next
             List.new [:quasiquote, read_form(rdr)]
           when '~' then
             rdr.next
             List.new [:unquote, read_form(rdr)]
           when '~@' then
             rdr.next
             List.new [:'splice-unquote', read_form(rdr)]
           when '^' then
             rdr.next
             a = read_form(rdr)
             b = read_form(rdr)
             List.new [:'with-meta', b, a]
           when '@' then
             rdr.next
             a = read_form(rdr)
             List.new [:deref, a]
           else
             atom = read_atom(rdr)
             atom
         end
end

def read_list(rdr, type, start='(', last=')')
  ast = type.new
  token = rdr.next
  if token != start
    raise "expected '#{last}', got #{token}"
  end
  while (token = rdr.peek) != last
    if token == ''
      raise "expected '#{last}', got #{token}"
    end
    ast.push(read_form(rdr))
  end
  rdr.next
  return ast
end

def read_atom(rdr)
  token = rdr.next
  case token
    when /^-?\d+$/ then
      token.to_i
    when /^".*"$/
      token[1..-2].gsub(/\\./, {"\\\\" => "\\", "\\n" => "\n", "\\\"" => '"'})
    when /^:/ then
      "\u029e#{token[1..-1]}"
    when 'nil' then
      nil
    when 'true' then
      true
    when 'false' then
      false
    else
      token.to_sym
  end
end

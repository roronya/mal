def pr_str(ast, print_readbly=true)
  case ast
    when Symbol
      ast.to_s
    when Integer
      ast.to_s
    when String
      if ast[0] == "\u029e"
        ":#{ast[1..-1]}"
      else
        print_readbly ? ast.inspect : ast
      end
    when NilClass
      'nil'
    when TrueClass
      ast.to_s
    when FalseClass
      ast.to_s
    when List
      "(#{ast.map {|e| pr_str(e, print_readbly)}.join(' ')})"
    when Vector
      "[#{ast.map {|e| pr_str(e, print_readbly)}.join(' ')}]"
    when Hash
      "{#{ast.to_a.flatten.map {|e| pr_str(e, print_readbly)}.join(' ')}}"
    when Function
      '#<function>'
  end
end


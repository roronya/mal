def pr_str(ast)
  case ast
    when Symbol
      ast.to_s
    when Integer
      ast.to_s
    when NilClass
      'nil'
    when TrueClass
      ast.to_s
    when FalseClass
      ast.to_s
    when List
      "(#{ast.map {|e| pr_str(e)}.join(' ')})"
    when Vector
      "[#{ast.map {|e| pr_str(e)}.join(' ')}]"
    when Hash
      "{#{ast.to_a.flatten.map {|e| pr_str(e)}.join(' ')}}"
    when Proc
      '#<function>'
  end
end


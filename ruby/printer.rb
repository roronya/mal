def pr_str(ast)
  case ast
    when Symbol then
      ast.to_s
    when Integer then
      ast.to_s
    when List then
      "(#{ast.map {|e| pr_str(e)}.join(' ')})"
    when Vector then
      "[#{ast.map {|e| pr_str(e)}.join(' ')}]"
    when Hash then
      "{#{ast.to_a.flatten.map {|e| pr_str(e)}.join(' ')}}"
  end
end


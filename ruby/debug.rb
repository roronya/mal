require_relative 'reader'

regex = /[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}()'"`,;]*)/
m = regex.match('~@hoge') # ~@
p m[0]
m = regex.match('[') # 予約記号
p m[0]
m = regex.match('"hoge"') # 文字列
p m[0]
m = regex.match('; hige') # コメント
p m[0]
m = regex.match('hoge') # その他
p m[0]

m = regex.match('(123 456)')
p m

p '(123 456)'.split(regex)

p tokenizer('( 123 456 789 )').reject do |token|
  token.empty?
end

p tokenizer('( 123 456 789 )').reject {|token| token.empty?}

p tokenizer '(1 2 3)'
p read_str '(1 2 3)'

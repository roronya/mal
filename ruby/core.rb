require_relative 'types'
require_relative 'printer'
require_relative 'reader'

$core_ns = {
    '+': ->(a, b) {a+b},
    '-': ->(a, b) {a-b},
    '*': ->(a, b) {a*b},
    '/': ->(a, b) {a/b},
    list: ->(*args) {List.new args},
    list?: ->(arg) {List === arg},
    empty?: ->(list) {list.empty?},
    count: ->(list) {list ? list.size : 0},
    '=': ->(a, b) {a===b},
    '>': ->(a, b) {a>b},
    '>=': ->(a, b) {a>=b},
    '<': ->(a, b) {a<b},
    '<=': ->(a, b) {a<=b},
    'pr-str': ->(*a) {a.map {|e| pr_str(e, true)}.join(' ')},
    str: ->(*a) {a.map {|e| pr_str(e, false)}.join('')},
    prn: ->(*a) {puts a.map {|e| pr_str(e, true)}.join(' ')},
    println: ->(*a) {puts a.map {|e| pr_str(e, false)}.join(' ')},
    'read-string': ->(a) {read_str(a)},
    slurp: ->(a) {File.read(a)},
    atom: ->(a) {Atom.new(a)},
    atom?: ->(a) {Atom === a},
    deref: ->(a) {a.val},
    reset!: ->(a, b) {a.val = b},
    swap!: ->(*a) {a[0].val = a[1][*[a[0].val].concat(a.drop(2))]},
    cons: ->(a, b) {List.new b.dup.unshift(a)},
    concat: ->(*a) {List.new a.flatten},
    nth: ->(l, i) {
      if l[i]
        return l[i]
      else
        raise 'out of range'
      end},
    first: ->(l) {
      if l and !l.empty?
        l[0]
      else
        nil
      end},
    rest: ->(l) {
      if l
        List.new(l.drop(1))
      else
        List.new
      end},
    apply: ->(*a) {
      raise 'unexpected argument' if !(Function === a[0] && (Vector === a[-1] || List === a[-1]))
      return a[0][*a.drop(1)]
    },
    map: ->(f, l) {
      raise 'unexpected argument' if !(Function === f && Vector === l || List === l)
      return List.new l.map {|e| f[e]}
    },
    nil?: ->(a) {
      if a
        false
      else
        true
      end},
    true?: ->(a) {
      if a
        true
      else
        false
      end
    },
    false?: ->(a) {
      if a
        false
      else
        true
      end
    },
    symbol?: ->(a) {Symbol === a},
    symbol: ->(a){a.to_sym},
    keyword: ->(a){"\u029e#{a}"},
    keyword?: ->(a){a[0] == '\u029e'},
    vector: ->(*a){Vectore.new a},
    vector?: ->(a){Vector === a},
    'hash-map': ->(*a){a.each_slice(2).to_h},
    map?: ->(a){Hash === a},
    assoc: ->(a, *b){
      unless Hash === a
        raise 'unexpected argument'
      end
      r = a.dup
      b.each_slice(2).each{|k,v|
        r[k] = v
      }
      return r
    },
    dissoc: ->(a, *b) {
      unless Hash ===a
        raise 'unexpected argument'
      end
      r = a.dup
      b.each{|e|
      r.delete(e)
      }
      return r
    },
    get: ->(h, k) {
      unless Hash === h
        raise 'unexpected argument'
      end
      return h[k]
    },
    contains?: ->(h, k) {
      unless Hash === h
        raise 'unexpected argument'
      end
      return h.include?(k)
    },
    keys: ->(h) {
      h.keys
    },
    vals: ->(h){h.values},
    sequential?: ->(a) {Vector === a || List === a},
    throw: ->(a){raise a}
}

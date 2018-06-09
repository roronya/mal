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
}

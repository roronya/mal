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
    slurp: ->(a) {File.read(a)}
}

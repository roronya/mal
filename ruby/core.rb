require_relative 'types'

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
    '<=': ->(a, b) {a<=b}
}

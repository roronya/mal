#! /usr/bin/env hy

(import [types [FunctionType :as function]])
(import [hy.models [HySymbol :as sym HyKeyword :as key]])

(defn pr_str [arg]
  (setv arg_type (type arg))
  (if (= sym arg_type) (arg.format)
      (= str arg_type) arg
      (= key arg_type) arg
      (none? arg) "nil"
      (= bool arg_type) (if arg "true" "false")
      (= int arg_type) (str arg)
      (= dict arg_type) (.format "{{{0}}}"
                         (.join " "
                                (list-comp
                                  (.format "{0} {1}"
                                           (pr_str (get node 0))
                                           (pr_str (get node 1)))
                                  [node (.items arg)])))
      (= list arg_type) (.format
                          "[{0}]"
                          (.join " " (list-comp (pr_str node) [node arg])))
      (= tuple arg_type) (.format
                          "({0})"
                          (.join " " (list-comp (pr_str node) [node arg])))
      (= function arg_type) "#<function>"))

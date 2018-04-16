#! /usr/bin/env hy

(import [reader [read_str]])
(import [printer [pr_str]])
(import [hy.models [HySymbol :as sym]])
(import [env [Env]])
(import [more_itertools [chunked]])

(defn eval_ast [ast env]
  (setv head (nth ast 0))
  (setv arg0 (nth ast 1))
  (setv arg1 (nth ast 2))
  (if (= (sym "def!") head)
      (do (.set env arg0 (EVAL arg1 env))
          (.get env arg0))
      (= (sym "let*") head)
      (do (setv new_env (Env))
          (assoc new_env.data :outer env)
          (for [[key value] (chunked arg0 2)]
            (.set new_env key (EVAL value new_env)))
          (EVAL arg1 new_env))
      ((EVAL head env)
        (EVAL arg0 env)
        (EVAL arg1 env))))

(defn READ [arg]
  (read_str arg))

(defn EVAL [ast env]
  (if (isinstance ast tuple) (eval_ast ast env)
      (isinstance ast list) (list-comp (EVAL element env) [element ast])
      (isinstance ast dict) (dict-comp key (EVAL value env) [[key value] (.items ast)])
      (isinstance ast sym) (.get env ast)
      ast))

(defn PRINT [arg]
  (pr_str arg))

(defn rep [arg env]
  (PRINT (EVAL (READ arg) env)))

(defmain [&rest args]
  (setv env (Env))
  (.set env "+" (fn [a b] (+ a b)))
  (.set env "-" (fn [a b] (- a b)))
  (.set env "*" (fn [a b] (* a b)))
  (.set env "/" (fn [a b] (int (/ a b))))
  (.set env "outer" None)
  (while True
    (try
      (do
        (setv arg (input "user> "))
        (when (= "" arg) (continue))
        (print (rep arg env)))
      (except [e EOFError] (break))
      (except [e Exception] (print e)))))

#! /usr/bin/env hy

(import [reader [read_str]])
(import [printer [pr_str]])
(import [hy.models [HySymbol :as sym]])
(import [env [Env]])
(import [more_itertools [chunked]])

(defn eval_ast [ast env]
  (if (= list (type ast)) (return (list-comp
                                    (eval_ast element env)
                                    [element ast]))
      (= dict (type ast)) (return (dict-comp
                                    key (eval_ast value env)
                                    [[key value] (.items ast)]))
      (= tuple (type ast))
      (do (setv head (get ast 0))
          (if (= (sym "def!") head)
              (do (.set env (get ast 1) (get ast 2)) (eval_ast (get ast 1) env))
              (= (sym "let*") head)
              (do (setv new_env (Env))
                  (setv new_env.outer env)
                  (for [[key value] (chunked (get ast 1) 2)]
                    (.set new_env key (eval_ast value env)))
                  (eval_ast (get ast 2) new_env))
              ((.get env (get ast 0))
                (eval_ast (get ast 1) env)
                (eval_ast (get ast 2) env))))
      (= sym (type ast)) (.get env ast)
      ast))

(defn READ [arg]
  (read_str arg))

(defn EVAL [ast env]
  (eval_ast ast env))

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
      (except [e Exception] (print e)))))

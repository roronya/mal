#! /usr/bin/env hy

(import [reader [read_str]])
(import [printer [pr_str]])
(import [hy.models [HySymbol :as sym]])
(import [env [Env]])
(import [more_itertools [chunked]])

(list(map (fn [x] (+ 1 x)) [1 2]))

(defn eval_ast [ast env]
  (if (instance? tuple ast) (tuple (map (fn [el] (EVAL el env)) ast))
      (instance? list ast) (list-comp (EVAL el env) [el ast])
      (instance? dict ast) (dict-comp k (EVAL v env) [[k v] (.items ast)])
      (instance? sym ast) (.get env ast)
      ast))

(defn READ [arg]
  (read_str arg))

(defn EVAL [ast env]
  (if (not (instance? tuple ast))
      (eval_ast ast env)
      (do
        (setv [a0 a1 a2] [(nth ast 0) (nth ast 1) (nth ast 2)])
        (if (= (sym "def!") a0)
            (do (.set env a1 (EVAL a2 env))
                (.get env a1))
            (= (sym "let*") a0)
            (do (setv new_env (Env))
                (assoc new_env.data :outer env)
                (for [[key value] (chunked a1 2)]
                  (.set new_env key (EVAL value new_env)))
                (EVAL a2 new_env))
            (do
              (setv el (eval_ast ast env)
                    f (first el)
                    args (list (rest el)))
              (f #*args))))))

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

#! /usr/bin/env hy

(import [reader [read_str]]
        [printer [pr_str]]
        [hy.models [HySymbol :as sym]]
        [env [Env]]
        [more_itertools [chunked]]
        [core [ns]])

(defn eval_ast [ast env]
  (if (instance? tuple ast) (tuple (map (fn [el] (EVAL el env)) ast))
      (instance? list ast) (list-comp (EVAL el env) [el ast])
      (instance? dict ast) (dict-comp k (EVAL v env) [[k v] (.items ast)])
      (instance? sym ast) (.get env ast)
      ast))

(defn READ [arg]
  (read_str arg))

(defn EVAL [ast env]
  (while True
    ;;(print ast)
    (if (not (instance? tuple ast))
        (eval_ast ast env)
        (do
          (setv [a0 a1 a2] [(nth ast 0) (nth ast 1) (nth ast 2)])
          (if (= (sym "def!") a0)
              (do (.set env a1 (EVAL a2 env))
                  (.get env a1))
              (= (sym "let*") a0)
              (do (setv env (Env))
                  (assoc new_env.data :outer env)
                  (for [[key value] (chunked a1 2)]
                    (.set new_env key (EVAL value new_env)))
                  (setv ast a2)
                  (continue))
              (= (sym "do") a0)
              (do (setv evals
                        (list-comp (EVAL element env)
                                   [element (list (butlast ast))]
                                   (!= element (sym "do"))))
                  (setv ast (last ast))
                  (continue)
              (= (sym "if") a0)
              (do (setv condition (EVAL a1 env))
                  (if
                    (if (instance? bool condition) condition
                        (or (= condition 0)
                            (= condition "")
                            (= condition (tuple))
                            (= condition []))
                        True
                        condition)
                    (setv ast a2)
                    (setv ast (nth ast 3))))
              (= (sym "fn*") a0)
              (fn [&rest args]
                (setv fn_env (Env a1 (or args [])))
                (assoc fn_env.data :outer env)
                (EVAL a2 fn_env))
              (do
                (setv el (eval_ast ast env)
                      f (first el)
                      args (list (rest el)))
                (f #*args))))))))

(defn PRINT [arg]
  (pr_str arg))

(defn rep [arg env]
  (PRINT (EVAL (READ arg) env)))

(defmain [&rest args]
  (setv env (Env (ns.keys) (ns.values)))
  (while True
    (try
      (do
        (setv arg (input "user> "))
        (when (= "" arg) (continue))
        (print (rep arg env)))
      (except [e EOFError] (break))
      (except [e Exception] (print e)))))
(defn read_keyword [rdr]
  (.next rdr)
  (key ))

#! /usr/bin/env hy

(import [reader [read_str]]
        [printer [pr_str]]
        [hy.models [HySymbol :as sym]]
        [env [Env]]
        [more_itertools [chunked]]
        [core [ns]])

(defn eval_ast [ast env]
  ;;(print ast)
  (if (= list (type ast)) (return (list-comp
                                    (eval_ast element env)
                                    [element ast]))
      (= dict (type ast)) (return (dict-comp
                                    key (eval_ast value env)
                                    [[key value] (.items ast)]))
      (= tuple (type ast))
      (do (setv head (get ast 0))
          (if (= (sym "def!") head)
              (do (.set env (get ast 1) (eval_ast (get ast 2) env))
                  (.get env (get ast 1)))
              (= (sym "let*") head)
              (do (setv new_env (Env))
                  (assoc new_env.data :outer env)
                  (for [[key value] (chunked (get ast 1) 2)]
                    (.set new_env key (eval_ast value new_env)))
                  (eval_ast (get ast 2) new_env))
              (= (sym "do") head)
              (do (setv evals (list-comp (eval_ast element env)
                                         [element ast ]
                                         (!= element (sym "do"))))
                  (get evals -1))
              (= (sym "if") head)
              (do (setv condition (eval_ast (get ast 1) env))
                  (setv element1 (eval_ast (nth ast 2) env))
                  (setv element2 (eval_ast (nth ast 3) env))
                  (setv element1_type (type element1))
                  (setv element2_type (type element2))
                  (if
                    (if (or (= condition 0) (= condition (sym "")) (= condition ())) True)
                    element1 element2))
              (= (sym "fn*") head)
              (fn [&rest args]
                (setv fn_env (Env (get ast 1) (or args [])))
                (assoc fn_env.data :outer env)
                (eval_ast (get ast 2) fn_env))
              (do (setv l (list-comp (eval_ast element env) [element ast]))
                  ((get l 0) #*(rest l)))))
      (= sym (type ast)) (if (and (= "\"" (get ast 0)) (= "\"" (get ast -1)))
                             ast
                             (.get env ast))
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
  (setv env (Env (ns.keys) (ns.values)))
  (.set env "outer" None)
  (while True
    (try
      (do
        (setv arg (input "user> "))
        (when (= "" arg) (continue))
        (print (rep arg env)))
      (except [e EOFError] (break))
      (except [e Exception] (print e)))))

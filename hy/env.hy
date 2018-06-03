#! /usr/bin/env hy

(defclass Env []
  (defn __init__ [self &optional [binds []] [exprs []] [outer None]]
    (setv self.data {:outer outer})
    (for [[key value] (zip binds exprs)]
      (assoc self.data key value)))
  (defn set [self key value]
    (assoc self.data key value))
  (defn find [self key]
    (if (in key self.data)
        self
        (do
          (setv outer (get self.data :outer))
          (if (none? outer)
              None
              (.find outer key)))))
  (defn get [self key]
    (setv env (self.find key))
    (if (none? env)
        (raise (ValueError (.format "'{0}' not found." key)))
        (get env.data key))))

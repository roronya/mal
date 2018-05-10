#! /usr/bin/env hy

(defclass Env []
  (defn __init__ [self &optional [binds []] [exprs []] [outer None]]
    (setv self.data {:outer outer})
    (for [[key value] (zip binds exprs)]
      (assoc self.data key value)))
  (defn set [self key value]
    (assoc self.data key value))
  (defn find [self key]
    (try (get self.data key)
         (except [e KeyError]
           (setv outer (get self.data :outer))
           (if (none? outer)
               None
               (.find outer key)))))
  (defn get [self key]
    (setv value (self.find key))
    (if (none? value)
        (raise (ValueError (.format "'{0}' not found." key)))
        value)))

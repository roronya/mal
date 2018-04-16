(defclass MalType [])

(defclass MalTuple [MalType tuple])
(defclass MalList [MalType list])
(defclass MalHashMap [MalType dict])
(defclass MalInt [MalType int])
(type(+(MalInt 1) (MalInt 2)))
(type (MalInt 1))
()

(MalTuple [1 2 3])

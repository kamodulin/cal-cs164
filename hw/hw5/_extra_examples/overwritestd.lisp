(print 
(let ((stdout (open-out "/tmp/cs164/test"))) 
(do (output stdout "hello") (close-out stdout) (input (open-in "/tmp/cs164/test") 5))))
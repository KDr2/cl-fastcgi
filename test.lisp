;;;
;;; cl-fastcgi : http://kdr2.net/cl-fastcgi.html
;;;
;;; Author : KDr2 <killy.draw@gmail.com>  http://kdr2.net
;;;
;;; License : BSD License
;;;


;;; A1. load cl-fascgi asdf
(asdf:operate 'asdf:load-op 'cl-fastcgi)
;;; A2. load libfcgi.so
;;
(cl-fastcgi:load-libfcgi)

;;; B1. simple app using fcgi-style interface
(defun simple-app (req)
  (let ((c (format nil "Content-Type: text/plain

Hello, I am a fcgi-program using Common-Lisp
~%~A~%"
                   (cl-fastcgi:fcgx-getenv req)))
        (d (cl-fastcgi:fcgx-read req))) ;; get post body
    (cl-fastcgi:fcgx-puts req c)
    (cl-fastcgi:fcgx-puts req (format nil "~A" d))))

;;; B2. run the simple app above
(defun run-app-0 ()
  (cl-fastcgi:simple-server #'simple-app))

(defun run-app-0.5 ()
  (cl-fastcgi:socket-server #'simple-app
                                     :inet-addr "0.0.0.0"
                                     :port 9000))
#+nil
(run-app-0)

;;; C1. app using WSGI-style interface
(defun wsgi-app (env start-response)
  (funcall start-response "200 OK" '(("X-author" . "Who?")
                                     ("Content-Type" . "text/html")))
  (let ((post (funcall (cdr (assoc :POST-READER env))))) ;; read post body
    (list "ENV (show in alist format): <br>" env
          "<br>LISP FEATURES (show in list format): <br>" *features*
          "<br>POST BODY(read once):<br>" post)))

;;; C2. run app above on 0.0.0.0:9000 (by default)
(defun run-app-1 ()
  (cl-fastcgi:socket-server
   (cl-fastcgi:make-serve-function #'wsgi-app)
   :inet-addr "0.0.0.0"
   :port 9000))

;;; C3. a nested WSGI-style app example
(defun wsgi-app2 (app)
  (lambda (env start-response)
    (let ((content-0 (funcall app env start-response))) ; call inner app
      ;;reset X-author in headers
      (funcall start-response nil '(("X-author" . "KDr2!")))
      (append '("Prefix <br/>")  content-0 '("<br/>Postfix")))))

;;; C5. run (test-app1 test-app2) nested app
(defun run-app-2 ()
  (cl-fastcgi:socket-server
   (cl-fastcgi:make-serve-function (wsgi-app2 #'wsgi-app))
   :inet-addr "0.0.0.0"
   :port 9000))

;;; D. pack the webapp to a executable file
#+sbcl
(defun make-exe (&optional (name "sbcl.fcgi"))
  (sb-ext:save-lisp-and-die name
                            :executable t
                            :purify t
                            :toplevel (lambda ()
                                        (unwind-protect (run-app-2)
                                          (sb-ext:quit)))))


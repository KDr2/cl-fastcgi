;;;
;;; cl-fastcgi : https://kdr2.com/project/cl-fastcgi.html
;;;
;;; Author : KDr2 <zhuo.dev@gmail.com>  https://kdr2.com
;;;
;;; License : BSD License
;;;

(asdf:defsystem #:cl-fastcgi
  :name "cl-fastcgi"
  :author "KDr2 <zhuo.dev@gmail.com>"
  :licence "BSD License"
  :description "FastCGI wrapper for Common Lisp"
  :depends-on (#:usocket
               #:cffi
               #+sbcl
               #:sb-bsd-sockets)
  :serial t
  :components ((:file "package")
               (:file "cl-fastcgi")
               (:file "cl-fastcgi-x")
               (:file "cl-fastcgi-server")
               (:file "cl-fastcgi-wsgi")))

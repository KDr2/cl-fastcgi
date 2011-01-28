;;;
;;; cl-fastcgi : http://kdr2.net/cl-fastcgi.html
;;;
;;; Author : KDr2 <killy.draw@gmail.com>  http://kdr2.net
;;;
;;; License : BSD License
;;;


(defpackage #:cl-fastcgi
  (:use :cl :cffi)
  (:export #:load-libfcgi
           ;;internal
           #:fcgx-init
           #:fcgx-init-request
           #:fcgx-accept
           #:fcgx-finish
           #:fcgx-puts
           #:fcgx-read
           #:fcgx-read-all
           #:fcgx-getparam
           #:fcgx-getenv
           ;;servers
           #:simple-server
           #:socket-server
           ;;wsgi interface
           #:make-serve-function))

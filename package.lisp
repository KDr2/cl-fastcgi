;;;
;;; cl-fastcgi : https://kdr2.com/project/cl-fastcgi.html
;;;
;;; Author : KDr2 <zhuo.dev@gmail.com>  https://kdr2.com
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
           #:fcgx-flush
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

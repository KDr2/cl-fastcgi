;;;
;;; cl-fastcgi : http://kdr2.net/cl-fastcgi.html
;;;
;;; Author : KDr2 <killy.draw@gmail.com>  http://kdr2.net
;;;
;;; License : BSD License
;;;

(in-package :cl-fastcgi)

(defparameter *libfcgi-loaded* nil)

(defun load-libfcgi (&optional (path "/usr/lib/libfcgi.so"))
  (if *libfcgi-loaded*
      "libfcgi already loaded!"
      (progn
        (define-foreign-library libfcgi
          (:darwin (:or path "libfcgi.dylib"))
          (:unix (:or path "libfcgi.so"))
          (:t (:default "libfcgi")))
        (use-foreign-library libfcgi)
        (setf *libfcgi-loaded* t))))

(cl-fastcgi:load-libfcgi)

(defun split-headers-to-cons (str)
  (let ((pos (position #\= str :start 1)))
    (if pos
        (cons (subseq str 0 pos) (subseq str (1+ pos)))
        nil)))


(defun default-headers ()
  (list (cons "X-powered-by" "SBCL:cl-fastcgi")
        (cons "Content-Type" "text/html")))

(defun merge-headers (old-headers new-headers)
  (dolist (item new-headers)
    (let ((v (member (car item) old-headers :key #'car :test #'equal)))
      (if v
          (setf (cdar v) (cdr item))
          (push item old-headers))))
  old-headers)


(defun usocket-to-fd (usock)
  (let ((nsock (usocket:socket usock)))
    #+(or sbcl ecl)
    (sb-bsd-sockets:socket-file-descriptor nsock)
    #+(or cmu lispworks)
    nsock
    ;;#+(acl-socket)
    ;;(socket-os-fd nsock)
    #+ccl
    (ccl:socket-os-fd nsock)
    #+clisp
    (socket:stream-handles nsock)
    #-(or sbcl cmu clisp ccl lispworks ecl)
    (error "not supported!")))

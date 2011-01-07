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
    #+sbcl
    (sb-bsd-sockets:socket-file-descriptor nsock)
    #+cmu
    nsock
    #+clisp
    (SOCKET:STREAM-HANDLES nsock)
    #-(or sbcl cmu clisp)
    (error "not supported!")))

;;;
;;; cl-fastcgi : http://kdr2.net/cl-fastcgi.html
;;;
;;; Author : KDr2 <killy.draw@gmail.com>  http://kdr2.net
;;;
;;; License : BSD License
;;;

(in-package :cl-fastcgi)

(defun server-on-fd (func fd &key (flags 0))
  (fcgx-init)
  (with-foreign-object (req 'fcgx-request)
    (fcgx-init-request req fd flags)
    (do ((rc (fcgx-accept req) (fcgx-accept req)))
        ((< rc 0) "ACCEPT ERROR")
      (funcall func req)
      (fcgx-finish req))))

#+sbcl
(defun server-on-fd-threaded (func fd &key (flags 0) (threads 4))
  (fcgx-init)
  (do ((count 0 (1+ count)))
      ((>= count (1- threads)) 'THREADS-START-DONE)
    (sb-thread:make-thread (lambda ()
                             (server-on-fd func fd :flags flags))))
  (server-on-fd func fd :flags flags))

#-sbcl
(defun server-on-fd-threaded (func fd &key (flags 0) (threads 4))
  (declare (ignore threads))
  (server-on-fd func fd :flags flags))

(defun simple-server (func)
  (server-on-fd func 0))

(defun simple-server-threaded (func &key (threads 4))
  (server-on-fd-threaded func 0 :threads threads))


(defun socket-server (func &key
                      (inet-addr "0.0.0.0")
                      (port 9000))
  (let ((sock nil))
    (setf sock (usocket:socket-listen inet-addr port :reuse-address t :backlog 128))
    (server-on-fd func (usocket-to-fd sock))))

(defun socket-server-threaded (func &key
                               (inet-addr "0.0.0.0")
                               (port 9000)
                               (threads 4))
  (let ((sock nil))
    (setf sock (usocket:socket-listen inet-addr port :reuse-address t :backlog 128))
    (server-on-fd-threaded func
                           (usocket-to-fd sock)
                           :threads threads)))


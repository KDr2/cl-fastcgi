;;;
;;; cl-fastcgi : http://kdr2.net/cl-fastcgi.html
;;;
;;; Author : KDr2 <killy.draw@gmail.com>  http://kdr2.net
;;;
;;; License : BSD License
;;;


(in-package :cl-fastcgi)

(defcstruct fcgx-request
    "FCGX_Request"
  (request-id :int)
  (role :int)
  (in :pointer)
  (out :pointer)
  (err :pointer)
  (envp :pointer)
  (params-ptr :pointer)
  (ipc-fd :int)
  (is-begin-processed :int)
  (keep-connection :int)
  (app-status :int)
  (nwriters :int)
  (flags :int)
  (listen-sock :int))


(defcfun ("FCGX_Init" fcgx-init) :int)

(defun fcgx-init-request (request sock flags)
  (foreign-funcall "FCGX_InitRequest"
                   :pointer request :int sock :int flags :int))

(defun fcgx-accept (req)
  (foreign-funcall "FCGX_Accept_r" :pointer req :int))

(defun fcgx-finish (req)
  (foreign-funcall "FCGX_Finish_r" :pointer req :int))

(defun fcgx-puts (req content &key (stream :out))
  (let ((ostr nil))
    (cond
      ((eql stream :err)
       (setf ostr (foreign-slot-value req 'fcgx-request 'err)))
      (t (setf ostr (foreign-slot-value req 'fcgx-request 'out))))
    (foreign-funcall "FCGX_PutS" :string content :pointer ostr :int)))


(defun fcgx-getparam (req key)
  (let ((env (foreign-slot-value req 'fcgx-request 'envp)))
    (foreign-funcall "FCGX_GetParam" :string key :pointer env :string)))

(defun fcgx-getenv (req)
  (let ((env (foreign-slot-value req 'fcgx-request 'envp))
        (flag t)
        (item nil)
        (ret nil))
    (setf env (convert-to-foreign env :pointer))
    (do ((index 0 (1+ index)))
        ((not flag) 'done)
      (setf item (convert-from-foreign (mem-aref env :pointer index) :string))
      (if item
          (push item ret)
          (setf flag nil)))
    (mapcar #'split-headers-to-cons ret)))

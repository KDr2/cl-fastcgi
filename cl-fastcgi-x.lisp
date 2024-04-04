;;;
;;; cl-fastcgi : https://kdr2.com/project/cl-fastcgi.html
;;;
;;; Author : KDr2 <zhuo.dev@gmail.com>  https://kdr2.com
;;;
;;; License : BSD License
;;;


(in-package :cl-fastcgi)

(defvar *read-buffer-size* 1024)

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

(defun fcgx-flush (req)
  (foreign-funcall "FCGX_FFlush"
                   :pointer (foreign-slot-value req 'fcgx-request 'out)
                   :int))

(defun fcgx-finish (req)
  (foreign-funcall "FCGX_Finish_r" :pointer req :int))

(defun fcgx-puts (req content &key (stream :out))
  (let ((ostr nil))
    (cond
      ((eql stream :err)
       (setf ostr (foreign-slot-value req 'fcgx-request 'err)))
      (t (setf ostr (foreign-slot-value req 'fcgx-request 'out))))
    (etypecase content
      ((vector (unsigned-byte 8))
       (with-pointer-to-vector-data (p content)
         (foreign-funcall "FCGX_PutStr"
                          :pointer p
                          :int (length content)
                          :pointer ostr
                          :int)))
      ;; Let foreign-funcall try to convert any non-vector to a :string
      (T (foreign-funcall "FCGX_PutStr"
                          :string content
                          :int #+sbcl (length (sb-ext:string-to-octets content))
                               #+ccl (ccl:string-size-in-octets content)
                               #+clisp (length (convert-string-to-bytes content))
                               #-(or sbcl ccl clisp) (babel:string-size-in-octets content)
                          :pointer ostr
                          :int)))))


;;TODO : make these bufffers thread-local?
(defun fcgx-read (req)
  (let* ((buf (foreign-alloc :char :count *read-buffer-size*))
         (istr (foreign-slot-value req 'fcgx-request 'in))
         (content
          (make-array *read-buffer-size*
                      :fill-pointer 0
                      :element-type '(unsigned-byte 8)))
         (readn
          (foreign-funcall "FCGX_GetStr" :pointer buf :int *read-buffer-size*
                           :pointer istr :int)))
    ;;copy data
    (loop for i from 0 upto (1- readn) do
         (vector-push (mem-aref buf :unsigned-char i) content))
    (foreign-free buf)
    (values content readn)))

(defun fcgx-read-all (req)
  (let ((contents nil)
        (length 0)
        (last-read *read-buffer-size*))
    (do ()
        ((< last-read *read-buffer-size*))
      (multiple-value-bind (c l) (fcgx-read req)
        (push c contents)
        (setf length (+ length l))
        (setf last-read l)))
    (setf contents (nreverse contents))
    (push 'vector contents)
    (values contents length)))

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

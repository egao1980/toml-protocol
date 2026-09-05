(in-package #:toml-backend-tomlet)

(defclass tomlet-backend (toml-backend) ()
  (:documentation "tomlet decode + first-party TOML emitter."))

(defun make-tomlet-backend ()
  (make-instance 'tomlet-backend))

(defun %stringish-vector-p (value)
  "Tomlet may emit character vectors instead of STRING."
  (and (vectorp value)
       (not (stringp value))
       (plusp (length value))
       (every #'characterp value)))

(defun %from-offset-datetime (dt)
  (let* ((moment (datetime-protocol:make-moment
                  (datetime-protocol:make-date
                   (tomlet/types:offset-datetime-year dt)
                   (tomlet/types:offset-datetime-month dt)
                   (tomlet/types:offset-datetime-day dt))
                  (datetime-protocol:make-time-of-day
                   (tomlet/types:offset-datetime-hour dt)
                   (tomlet/types:offset-datetime-minute dt)
                   (tomlet/types:offset-datetime-second dt)
                   (tomlet/types:offset-datetime-nanosecond dt))))
         (offset-seconds (* (tomlet/types:offset-datetime-offset dt) 60)))
    (datetime-protocol:make-zoned-moment moment offset-seconds nil)))

(defun %from-local-datetime (dt)
  (datetime-protocol:make-moment
   (datetime-protocol:make-date
    (tomlet/types:local-datetime-year dt)
    (tomlet/types:local-datetime-month dt)
    (tomlet/types:local-datetime-day dt))
   (datetime-protocol:make-time-of-day
    (tomlet/types:local-datetime-hour dt)
    (tomlet/types:local-datetime-minute dt)
    (tomlet/types:local-datetime-second dt)
    (tomlet/types:local-datetime-nanosecond dt))))

(defun %from-local-date (dt)
  (datetime-protocol:make-date
   (tomlet/types:local-date-year dt)
   (tomlet/types:local-date-month dt)
   (tomlet/types:local-date-day dt)))

(defun %from-local-time (dt)
  (datetime-protocol:make-time-of-day
   (tomlet/types:local-time-hour dt)
   (tomlet/types:local-time-minute dt)
   (tomlet/types:local-time-second dt)
   (tomlet/types:local-time-nanosecond dt)))

(defun %normalize (value)
  (cond
    ((tomlet/types:offset-datetime-p value) (%from-offset-datetime value))
    ((tomlet/types:local-datetime-p value) (%from-local-datetime value))
    ((tomlet/types:local-date-p value) (%from-local-date value))
    ((tomlet/types:local-time-p value) (%from-local-time value))
    ((hash-table-p value)
     (let ((out (make-hash-table :test #'equal)))
       (maphash (lambda (k v) (setf (gethash k out) (%normalize v))) value)
       out))
    ((stringp value) value)
    ((%stringish-vector-p value) (coerce value 'string))
    ((vectorp value) (map 'vector #'%normalize value))
    ((consp value) (mapcar #'%normalize value))
    (t value)))

(defun %source-string (source)
  (etypecase source
    (string source)
    ((vector (unsigned-byte 8))
     (encoding-protocol:decode source))
    (stream
     (with-output-to-string (o)
       (loop for c = (read-char source nil nil)
             while c do (write-char c o))))))

(defmethod backend-decode ((backend tomlet-backend) source &key)
  (declare (ignore backend))
  (handler-case
      (%normalize
       (if (pathnamep source)
           (tomlet:parse-file source)
           (tomlet:parse (%source-string source))))
    (toml-error (e) (error e))
    (error (e)
      (error 'toml-parse-error
             :message (format nil "TOML parse failed: ~A" e)))))

(defmethod backend-encode ((backend tomlet-backend) value &key stream)
  (declare (ignore backend))
  (handler-case
      (if stream
          (progn (emit-toml value stream) (values))
          (with-output-to-string (o)
            (emit-toml value o)))
    (toml-error (e) (error e))
    (error (e)
      (error 'toml-encode-error
             :message (format nil "TOML encode failed: ~A" e)))))

(defun use-tomlet-backend ()
  "Bind *TOML-BACKEND* to a fresh tomlet backend. Returns the backend."
  (prog1 (setf *toml-backend* (make-tomlet-backend))
    (install-serdes-toml-hooks)))

(use-tomlet-backend)

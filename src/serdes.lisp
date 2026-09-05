(in-package #:toml-protocol)

(defclass toml-serdes-backend (serdes-protocol:serdes-backend) ()
  (:documentation "serdes backend that delegates to *TOML-BACKEND*."))

(defun make-toml-serdes-backend ()
  (make-instance 'toml-serdes-backend))

(defmethod serdes-protocol:backend-encode ((backend toml-serdes-backend) value &key stream)
  (declare (ignore backend))
  (encode value :stream stream))

(defmethod serdes-protocol:backend-decode ((backend toml-serdes-backend) source &key)
  (declare (ignore backend))
  (decode source))

(defun use-toml-serdes-backend ()
  "Register and select the TOML serdes backend. Returns the backend."
  (let ((backend (make-toml-serdes-backend)))
    (serdes-protocol:register-format :toml backend)
    (setf serdes-protocol:*serdes-format* :toml
          serdes-protocol:*serdes-backend* backend)
    backend))

(defun install-serdes-toml-hooks ()
  "Register :toml with serdes-protocol when *TOML-BACKEND* is bound."
  (unless *toml-backend*
    (return-from install-serdes-toml-hooks nil))
  (use-toml-serdes-backend)
  t)

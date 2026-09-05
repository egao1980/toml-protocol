(in-package #:toml-protocol)

;;; Lisp mapping (see plan):
;;;   table        → hash-table (equal), string keys
;;;   array        → vector
;;;   no null      → omit keys
;;;   boolean      → t / nil
;;;   offset dt    → datetime-protocol zoned-moment
;;;   local dt     → datetime-protocol moment
;;;   local date   → datetime-protocol date
;;;   local time   → datetime-protocol time-of-day
;;;   numbers      → CL numbers

(defvar *toml-backend* nil
  "Current TOML backend object (satisfies BACKEND-ENCODE / BACKEND-DECODE).")

(defclass toml-backend () ()
  (:documentation "Base class for toml-protocol backends."))

(defgeneric backend-encode (backend value &key stream)
  (:documentation "Encode VALUE as TOML text, or write to STREAM when non-nil."))

(defgeneric backend-decode (backend source &key)
  (:documentation "Decode SOURCE (string, octets, pathname, or character stream)."))

(defun null-p (object)
  (eq object :null))

(defun true-p (object)
  (eq object t))

(defun false-p (object)
  (and (null object) (not (eq object :null))))

(defun encode (value &key stream)
  "Encode VALUE via *TOML-BACKEND*. Returns a string unless STREAM is given."
  (unless *toml-backend*
    (error 'toml-encode-error :message "*toml-backend* is unbound — load toml-backend-tomlet"))
  (backend-encode *toml-backend* value :stream stream))

(defun decode (source &key)
  "Decode SOURCE via *TOML-BACKEND*."
  (unless *toml-backend*
    (error 'toml-parse-error :message "*toml-backend* is unbound — load toml-backend-tomlet"))
  (backend-decode *toml-backend* source))

(defun encode-to-octets (value &key)
  (encoding-protocol:encode (encode value)))

(defun decode-octets (octets &key)
  (decode octets))

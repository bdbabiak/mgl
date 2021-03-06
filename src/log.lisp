(in-package :mgl-log)

;;; FIXDOC
(defsection @mgl-log (:title "Logging")
  (log-msg function)
  (with-logging-entry macro)
  (*log-file* variable)
  (*log-time* variable)
  (log-mat-room function))

(defun time->string (&optional (time (get-universal-time)))
  (destructuring-bind (second minute hour date month year)
      (subseq (multiple-value-list (decode-universal-time time)) 0 6)
    (format nil "~4,'0D-~2,'0D-~2,'0D ~2,'0D:~2,'0D:~2,'0D"
            year month date hour minute second)))

(defvar *log-file* nil)

(defvar *log-time* t)

(defun log-msg (format &rest args)
  (pprint-logical-block (*trace-output* nil)
    (when *log-time*
      (format *trace-output* "~A: " (time->string)))
    (pprint-logical-block (*trace-output* nil)
      (apply #'format *trace-output* format args)))
  (when *log-file*
    (with-open-file (s *log-file* :direction :output
                       :if-exists :append :if-does-not-exist :create)
      (pprint-logical-block (s nil)
        (when *log-time*
          (format s "~A: " (time->string)))
        (pprint-logical-block (s nil)
          (apply #'format s format args))))))

(defmacro with-logging-entry ((stream) &body body)
  `(log-msg "~A"
    (with-output-to-string (,stream)
      ,@body)))

(defun log-mat-room (&key (verbose t))
  (with-logging-entry (stream)
    (mgl-mat:mat-room :stream stream :verbose verbose)))

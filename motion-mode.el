(defun motion-get-rakefile-content ()
  (shell-command-to-string
   (format "cat `git ls-files $(git rev-parse --show-toplevel) | grep Rakefile | head -1`")))

(defun motion-detect-motion-project ()
  (with-temp-buffer
    (insert (motion-get-rakefile-content))
    (goto-char (point-min))
    (search-forward "Motion::Project::App" nil t)))

(define-derived-mode motion-mode
  ruby-mode
  "RMo"
  "motion-mode is provide a iOS SDK's dictonary for auto-complete-mode"
  )

(defun motion-upgrade-major-mode-if-motion-project ()
  (if (and (motion-detect-motion-project)
	   (equal major-mode 'ruby-mode))
      (motion-mode)
    nil))
	
(provide 'motion-mode)

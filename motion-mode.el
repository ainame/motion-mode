(defun motion-get-rakefile-content ()
  (shell-command-to-string
   (format "cat `git ls-files $(git rev-parse --show-toplevel) | grep Rakefile | head -1`")))

(defun motion-detect-motion-project ()
  (with-temp-buffer
    (insert (motion-get-rakefile-content))
    (goto-char (point-min))
    (search-forward "Motion::Project::App" nil t)))

(defun motion-mode-start ()
  ;; TODO: implement some keybindings
  )

(defun motion-mode-stop ()
  )

(define-derived-mode motion-mode
  ruby-mode
  "RMo"
  "motion-mode is provide a iOS SDK's dictonary for auto-complete-mode"
  (cond ((motion-mode)
	 (motion-mode-start))
	(t
	 (motion-mode-stop))))

(defun motion-upgrade-major-mode-if-motion-project ()
  (if (motion-detect-motion-project)
      (motion-mode)
    nil))
	
(provide 'motion-mode)




(defvar motion-execute-rake-buffer "*motion-rake*")

(defun motion-project-root ()
  (let ((root (locate-dominating-file default-directory "Rakefile")))
    (when root
      (expand-file-name root))))

(defun motion-project-p ()
  (let ((root (motion-project-root)))
    (when root
      (let ((rakefile (concat root "Rakefile")))
        (when (file-exists-p rakefile)
          (with-current-buffer (find-file-noselect rakefile)
            (goto-char (point-min))
            (search-forward "Motion::Project::App" nil t)))))))

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
	
;;;###autoload
(defun motion-execute-rake ()
  (interactive)
  (let ((root (motion-project-root)))
    (if (not root)
        (message "Here is not Ruby Motion Project")
      (let ((default-directory root)
            (buf (get-buffer-create motion-execute-rake-buffer))
            (cmd (motion-execute-rake-command)))
        (with-current-buffer buf
          (erase-buffer)
          (call-process-shell-command cmd nil t)
          (pop-to-buffer buf))))))

(provide 'motion-mode)

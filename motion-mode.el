;;; motion-mode.el --- major mode for RubyMotion enviroment

;; Copyright (C) 2013 by Satoshi Namai

;; Author: Satoshi Namai
;; URL: https://github.com/ainame/motion-mode
;; Version: 0.5.1
;; Package-Requires: ((flymake-easy "0.7") (flymake-cursor "1.0.2"))

;; Copyright (C) 2013 by Satoshi Namai <s.namai.2012 at gmail.com>
;;
;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation
;; files, to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject
;; to the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
;; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:

;;; Code:

(defcustom motion-flymake t
  "motion-flymake variable is the flag which whether your emacs open rubymotion-source with flymake-mode or don't"
  :type 'boolean
  :group 'motion-mode)

(defvar motion-execute-rake-buffer "motion-rake")
(defvar motion-convert-code-command
  (format "ruby %s" (concat (file-name-directory load-file-name) "bin/code_converter.rb")))
(defvar motion-get-rake-task-history nil)
(defvar motion-rake-task-list-cache nil)
(defvar motion-rake-task-buffer " *motion rake tasks*")

(defun motion-execute-rake-buffer-name ()
  (concat "*" motion-execute-rake-buffer "*"))

(defun motion-project-root ()
  (let ((root (locate-dominating-file default-directory "Rakefile")))
    (when root
      (expand-file-name root))))

(defun motion-project-p ()
  (let ((root (motion-project-root)))
    (when root
      (let ((rakefile (concat root "Rakefile")))
        (when (file-exists-p rakefile)
          (with-temp-buffer
	    (insert-file-contents rakefile)
            (goto-char (point-min))
            (search-forward "Motion::Project::App" nil t)))))))

;;;###autoload
(define-derived-mode motion-mode
  ruby-mode
  "RMo"
  "motion-mode is provide a iOS SDK's dictonary for auto-complete-mode"
  (progn
    ;; asynchronous caching rake tasks
    (let ((default-directory (motion-project-root)))
      (motion-get-rake-tasks (motion-bundler-p) t))
    (when (eq motion-flymake t)
      (motion-flymake-init))))

;;;###autoload
(defun motion-recognize-project ()
  (interactive)
  (when (and (eq major-mode 'ruby-mode) (motion-project-p))
    (motion-mode)))

(defun motion-get-rake-tasks (use-bundler &optional async-p)
  (if (not motion-rake-task-list-cache)
      (if async-p
          (motion-get-rake-tasks-async use-bundler)
        (motion-get-rake-tasks-synchronous use-bundler))
    motion-rake-task-list-cache))

(defun motion-collect-rake-tasks ()
  (with-current-buffer motion-rake-task-buffer
    (goto-char (point-min))
    (let ((tasks nil))
      (while (re-search-forward "^rake \\(\\S-+\\)" nil t)
        (push (match-string 1) tasks))
      (erase-buffer)
      (reverse tasks))))

(defun motion-collect-rake-task-sentinel (proc state)
  (when (eq (process-status proc) 'exit)
    (setq motion-rake-task-list-cache (motion-collect-rake-tasks))))

(defun motion-get-rake-tasks-async (use-bundler)
  (let* ((buf (get-buffer-create motion-rake-task-buffer))
         (rake (if use-bundler "bundle exec rake" "rake"))
         (cmd (format "%s --tasks" rake))
         (proc (start-process-shell-command "rake-tasks" buf cmd)))
    (set-process-sentinel proc 'motion-collect-rake-task-sentinel)))

(defun motion-get-rake-tasks-synchronous (use-bundler)
  (let* ((rake (if use-bundler "bundle exec rake" "rake"))
         (cmd (format "%s --tasks" rake))
         (buf (get-buffer-create motion-rake-task-buffer))
         (ret (call-process-shell-command cmd nil buf)))
    (unless (zerop ret)
      (error "Failed: %s. Please check Rakefile" cmd))
    (setq motion-rake-task-list-cache (motion-collect-rake-tasks))))

(defun motion-get-rake-sub-command (use-bundler)
  (if current-prefix-arg
      (let ((tasks (motion-get-rake-tasks use-bundler)))
        (completing-read "rake task: " tasks
                         nil nil nil 'motion-get-rake-task-history))))

(defun motion-construct-rake-command (bundler task)
  (cond ((and bundler task) `("bundle" nil "exec" "rake" ,task "--suppress-backtrace" ".*"))
        (bundler `("bundle" nil "exec" "rake" "--suppress-backtrace" ".*"))
        (task `("rake" nil ,task "--suppress-backtrace" ".*"))
        (t `("rake" nil "--suppress-backtrace" ".*"))))

(defsubst motion-bundler-p ()
  ;; default-directory should be top directory of project.
  (file-exists-p (concat default-directory "Gemfile.lock")))

(defun motion-execute-rake-command-execution (task)
  (let* ((use-bundler (motion-bundler-p))
         (buf (get-buffer-create (motion-execute-rake-buffer-name)))
         (sub-command (or task (motion-get-rake-sub-command use-bundler)))
         (params (motion-construct-rake-command use-bundler sub-command)))
    (message "%s" (mapconcat (lambda (p) (if p (concat p " ") "")) params ""))
    (apply 'make-comint motion-execute-rake-buffer params)
    (pop-to-buffer buf)))

(defun motion-execute-rake-command (task)
  (let ((root (motion-project-root)))
    (if (not root)
        (message "Here is not Ruby Motion Project")
      (let ((default-directory root))
	(motion-execute-rake-command-execution task)))))

;;;###autoload
(defun motion-execute-rake ()
  (interactive)
  (motion-execute-rake-command nil))

(defun motion-reload-app ()
  (interactive)
  (let ((buf (motion-execute-rake-buffer-name)))
    (when (get-buffer buf)
      (progn
        (with-current-buffer (get-buffer (motion-execute-rake-buffer-name))
          (set-process-query-on-exit-flag (get-buffer-process (current-buffer)) nil))
        (kill-buffer buf))))
  (motion-execute-rake-command nil))

(defun motion-flymake-init ()
  (progn
    (require 'flymake-easy)
    (require 'flymake-cursor)

    (defconst flymake-motion-err-line-patterns
      '(("^\\(.*\.rb\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3)))

    (defvar flymake-motion-executable "/Library/RubyMotion/bin/ruby"
      "The macruby executable to use for syntax checking.")

    ;; Invoke rubymotion with '-c' to get syntax checking
    (defun flymake-motion-command (filename)
      "Construct a command that flymake can use to check ruby-motion source."
      (list flymake-motion-executable "-w" "-c" filename))

    (defun flymake-motion-load ()
      "Configure flymake mode to check the current buffer's macruby syntax."
      (interactive)
      (flymake-easy-load 'flymake-motion-command
			 flymake-motion-err-line-patterns
			 'tempdir
			 "rb"))
    (custom-set-variables
     '(help-at-pt-timer-delay 0.3)
     '(help-at-pt-display-when-idle '(flymake-overlay)))
    (flymake-motion-load)
    ))

;;;###autoload
(defun motion-dash-at-point ()
  "This function open document by Dash.app."
  (interactive)
  (let ((keyword (thing-at-point 'word)))
    (princ keyword)
    (shell-command (format "open dash://%s" keyword))))

;;;###autoload
(defun motion-convert-code-region (start end)
  "convert code from Objective-C to RubyMotion.
This is inspired from https://github.com/kyamaguchi/SublimeObjC2RubyMotion.
"
  (interactive (list (region-beginning) (region-end)))
  (shell-command-on-region start end motion-convert-code-command nil t))

(provide 'motion-mode)
;;; motion-mode.el ends here

(require 'motion-mode)
(add-to-list 'ac-modes 'motion-mode)
(add-to-list 'ac-sources 'ac-source-dictionary)
(add-hook 'ruby-mode-hook 'motion-upgrade-major-mode-if-motion-project)
(define-key motion-mode-map (kbd "C-c C-c") 'motion-execute-rake)
(define-key motion-mode-map (kbd "C-c C-d") 'motion-dash-at-point)


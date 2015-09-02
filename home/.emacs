(add-to-list 'load-path "~/.emacs.d/lisp/")

(require 'cylc-mode)
(setq auto-mode-alist (append auto-mode-alist 
		      (list '("\\.rc$" . cylc-mode))))
(global-font-lock-mode t)

(require 'rose-conf-mode)

;; Extra settings not related to Rose / Cylc
(global-set-key [f5] 'undo)
(global-set-key [f6] 'shell)
(global-set-key [C-backspace] 'kill-this-buffer)
(global-set-key [C-left] 'kill-this-buffer)
(custom-set-variables
 '(backup-directory-alist (quote ((".*" . "~/.emacs.d/backups"))))
 '(column-number-mode t)
 '(display-time-day-and-date t)
 '(display-time-mode t)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(tool-bar-mode nil))

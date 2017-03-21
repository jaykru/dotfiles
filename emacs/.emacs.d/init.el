;; enable MELPA
(require 'package)
(add-to-list 'load-path "~/.emacs.d/elpa")
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))
(package-initialize)

(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)
(global-set-key (kbd "C-x g") 'magit-status)
(global-unset-key (kbd "C-z"))

;; highlight delims
(setq show-paren-delay 0)
(show-paren-mode 1)

;; autocomplete
(global-auto-complete-mode t)

;; quiet, you.
(setq ring-bell-function 'ignore)

;; no backups
(setq backup-inhibited t)

;; no autosaving
(setq auto-save-default nil)

;; ido-mode
(ido-mode t)
(ido-everywhere t)
(setq ido-enable-prefix nil
      ido-enable-flex-matching t
      ido-create-new-buffer 'always
      ido-use-filename-at-point 'guess
      ido-max-prospects 10
      ido-default-file-method 'selected-window)

;; auto-completion in minibuffer
(icomplete-mode +1)
(set-default 'imenu-auto-rescan t)

;; smex
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)

(setq default-frame-alist
      '((font . "Courier")
        (vertical-scroll-bars . nil)
        (horizontal-scroll-bars . nil)
        (tool-bar-lines . 0)
        (menu-bar-lines . 0)
        (left-fringe . 0)
        (right-fringe . 0)))

(set-face-attribute 'default nil :height 110)

;; mark theme as safe
(custom-set-variables
 '(custom-safe-themes
   (quote
    ("23ccf46b0d05ae80ee0661b91a083427a6c61e7a260227d37e36833d862ccffc" default))))
;; load it
(load-theme 'tao-yang)

;; tramp for sudo access
(require 'tramp)
(setq tramp-default-method "ssh")
(set-default 'tramp-default-proxies-alist (quote ((".*" "\\`root\\'" "/ssh:%h:"))))
(defun sudo-edit-current-file ()
  (interactive)
  (let ((position (point)))
    (find-alternate-file
     (if (file-remote-p (buffer-file-name))
         (let ((vec (tramp-dissect-file-name (buffer-file-name))))
           (tramp-make-tramp-file-name
            "sudo"
            (tramp-file-name-user vec)
            (tramp-file-name-host vec)
            (tramp-file-name-localname vec)))
       (concat "/sudo:root@localhost:" (buffer-file-name))))
    (goto-char position)))

(require 'em-smart)
(setq eshell-where-to-jump 'begin)
(setq eshell-review-quick-commands nil)
(setq eshell-smart-space-goes-to-end t)

(add-hook 'prog-mode-hook
          (lambda ()
            (progn
              (rainbow-delimiters-mode t))))

;; cl mode
(require 'paredit)
(add-hook 'lisp-mode-hook
          (lambda ()
            (progn
              (paredit-mode t)
              (slime-mode))))

;; SLIME
(require 'slime)
(setq slime-contribs '(slime-fancy))
(add-hook 'slime-repl-mode-hook 
          (lambda () (progn
                       (rainbow-delimiters-mode t)
                       (paredit-mode t))))
(setq inferior-lisp-program "sbcl.exe")
(slime-setup '(slime-fancy))

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (paredit-mode t)))

(require 'go-autocomplete)
(setenv "GOPATH" "/home/jaykru/go")
(add-hook 'go-mode-hook
          (lambda ()
            (progn
              (flycheck-mode)
              (add-hook 'before-save-hook 'gofmt-before-save)
              (auto-complete-mode 1))))

(defun my-asm-mode-hook ()
  ;; you can use `comment-dwim' (M-;) for this kind of behaviour anyway
  (local-unset-key (vector asm-comment-char))
  ;; asm-mode sets it locally to nil, to "stay closer to the old TAB behaviour".
  (setq tab-always-indent (default-value 'tab-always-indent)))

(add-hook 'asm-mode-hook #'my-asm-mode-hook)

(setq pdf-latex-command "pdflatex")

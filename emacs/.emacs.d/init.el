;; enable MELPA
(require 'package)
(add-to-list 'load-path "~/.emacs.d/elpa")
(add-to-list 'load-path "~/.emacs.d/lisp")
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))
(package-initialize)

(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)
(global-set-key (kbd "C-x g") 'magit-status)
(global-unset-key (kbd "C-z"))

;; org stuff
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

;; highlight delims
(setq show-paren-delay 0)
(show-paren-mode 1)

;; autocomplete
(global-auto-complete-mode t)

;; line numbers
(global-linum-mode)

;; quiet, you.
(setq ring-bell-function 'ignore)

;; ivy
(ivy-mode t)
(setq ivy-use-virtual-buffers t) (setq ivy-count-format "(%d/%d) ")

;; column numbers
(column-number-mode t)

(unicode-fonts-setup)
(set-frame-font "Menlo")
(setq default-frame-alist
      '((font . "Menlo-13")
	(vertical-scroll-bars . nil)
	(horizontal-scroll-bars . nil)
	(tool-bar-lines . 0)
	(menu-bar-lines . 0)
	))

;; load theme
(setq tao-theme-use-sepia t)
(setq tao-theme-sepia-depth 3)
(setq tao-theme-sepia-saturation 1.10)
(load-theme 'tao-yin t)

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

(exec-path-from-shell-initialize)
(setq epa-pinentry-mode 'loopback)
(pinentry-start)

(add-to-list 'load-path "/usr/local/Cellar/agda/HEAD-45d584d/share/x86_64-osx-ghc-8.6.4/Agda-2.6.0/emacs-mode/")
(require 'agda2-mode)

(add-hook 'prog-mode-hook
	  (lambda ()
	    (progn
	      (rainbow-delimiters-mode t)
	      (global-undo-tree-mode t))))

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
(setq inferior-lisp-program "sbcl")
(slime-setup '(slime-fancy))

(add-hook 'emacs-lisp-mode-hook
	  (lambda ()
	    (paredit-mode t)))

(defun my-asm-mode-hook ()
  ;; you can use `comment-dwim' (M-;) for this kind of behaviour anyway
  (local-unset-key (vector asm-comment-char))
  ;; asm-mode sets it locally to nil, to "stay closer to the old TAB behaviour".
  (setq tab-always-indent (default-value 'tab-always-indent)))

(add-hook 'asm-mode-hook #'my-asm-mode-hook)

;; unicode bullets
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

;; todo keywords
(setq org-todo-keywords
      '((sequence "TODO(t)" "|" "DONE(d)")
        (sequence "|" "CANCELED(c)")
        (sequence "WAIT(w)" "|")))

;; todo keyword faces
(setq org-todo-keyword-faces
       '(("TODO". (:foreground "red" :background "#fedfe1" :box '(:line-width 1 :style released-button)))
        ("DONE". (:foreground "#40883f" :background "#A8D8B9" :box '(:line-width 1 :style released-button)))
        ("WAIT" . (:foreground "orange" :background "#FFF689" :box '(:line-width 1 :style released-button)))
        ("CANCELED" . (:foreground "black" :strike-through t :background "#d8d7da" :box '(:line-width 1 :style released-button)))))

;; alerts
(require 'org-alert)
(require 'alert)
(setq alert-default-style 'notifier)
(org-alert-enable)
(setq org-alert-interval 21600)

(setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))

;; preserve clocks between sessions
(setq org-clock-persist 'history)
(org-clock-persistence-insinuate)

(setq pdf-latex-command "luatex") ; ad fontes! :)
(setq preview-scale-function 2.0)

(load "~/.emacs.d/lisp/PG/generic/proof-site")
(setq coq-prog-name "coqtop")
(add-hook 'coq-mode-hook
	  (lambda ()
	    (progn
	    (company-coq-mode t)
	      (rainbow-delimiters-mode t))))
(setq pdf-latex-command "lualatex") ; ab fontes :'(

(load-file (let ((coding-system-for-read 'utf-8))
                (shell-command-to-string "agda-mode locate")))

(add-hook 'racket-mode-hook
  (lambda ()
    (progn
       (paredit-mode t))))

(display-battery-mode)

(require 'quelpa-use-package)
   (use-package matrix-client
   :quelpa ((matrix-client :fetcher github :repo "alphapapa/matrix-client.el"
   :files (:defaults "logo.png" "matrix-client-standalone.el.sh"))))

(setq mac-command-modifier 'meta)

  ;; enable MELPA
  (require 'package)
    (add-to-list 'load-path "~/.emacs.d/elpa")
    (add-to-list 'load-path "~/.emacs.d/lisp")
    (setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
			     ("melpa" . "https://melpa.org/packages/")))
    (setq package-selected-packages '(cargo magit rg change-inner racer unicode-fonts undo-tree tuareg tao-theme rainbow-delimiters plan9-theme pinentry paredit org-bullets markdown-mode visual-regexp ivy flycheck exec-path-from-shell auto-complete elpy moe-theme slime))
    (package-initialize)
    (package-install-selected-packages)

(global-set-key (kbd "C-x g") 'magit-status)
(global-unset-key (kbd "C-z"))

;; org stuff
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

;; ugh
(electric-indent-mode -1)
(electric-pair-mode 0)

;; highlight delims
(setq show-paren-delay 0)
(show-paren-mode 1)

;; line numbers
(global-linum-mode)

;; quiet, you.
(setq ring-bell-function 'ignore)

;; ivy
(ivy-mode t)
(setq ivy-use-virtual-buffers t) (setq ivy-count-format "(%d/%d) ")

;; column numbers
(column-number-mode t)

;; semantic editing
(require 'change-inner)
(global-set-key (kbd "M-i") 'change-inner)
(global-set-key (kbd "M-o") 'change-outer)

  ;  (unicode-fonts-setup)
  (let ((my-frame-font
	 (if (eq system-type 'darwin)
	     "Menlo"
	   "Iosevka")))
    (setq default-frame-alist
	  `((font . ,my-frame-font)
	    (vertical-scroll-bars . nil)
	    (horizontal-scroll-bars . nil)
	    (tool-bar-lines . 0)
      	    ; formerly set to 0, which broke full-screen
	    ; on mitsuharu's emacs 27 build for macos.
	    ; unsure why it was zero in the first place,
	    ; so whatever.	      
	    (menu-bar-lines . 1))))

;; load theme
(setq tao-theme-use-sepia t)
(setq tao-theme-sepia-depth 3)
(setq tao-theme-sepia-saturation 1.10)
(load-theme 'sanityinc-solarized-light t)

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

(setq epa-pinentry-mode 'loopback)
; (pinentry-start)

;; no backups
(setq make-backup-files nil)

  ;; this needs to happen early because other part of the config depend
  ;; on PATH being set correctly.
  (when (eq system-type 'darwin)
      (exec-path-from-shell-initialize)
      (setq mac-command-modifier 'meta)
      (setq mac-option-modifier 'meta)
      ; fixes a bug(?) in emacs 27
      (setq default-directory "~/")
      (setq command-line-default-directory "~/"))

(add-hook 'prog-mode-hook
	  (lambda ()
	    (progn
	      (rainbow-delimiters-mode t))))

(add-hook 'julia-mode-hook
	  (lambda ()
	    (progn 
	      (local-set-key (kbd "C-c C-c") 'julia-repl-send-region-or-line))))

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

;; encrypted note archives
(setq org-archive-location "~/org/archive.org.gpg::")

;; alerts
(require 'org-alert)
(require 'alert)
(setq alert-default-style 'notifier)
(org-alert-enable)
(setq org-alert-interval 21600)

(setq org-format-latex-options (plist-put org-format-latex-options :scale 1.5))

;; preserve clocks between sessions
(setq org-clock-persist 'history)
(org-clock-persistence-insinuate)

(setq org-default-notes-file (concat "~/org" "/notes.org.gpg"))

(setq pdf-latex-command "luatex") ; ad fontes! :)
(add-hook 'auctex-mode-hook
	    (lambda ()
	      (progn
	      (prettify-symbols-mode t))))

  (setq coq-prog-name "coqtop")
  ;; (setq company-coq-disabled-features '(prettify-symbols))
  (add-hook 'coq-mode-hook
	    (lambda ()
	      (progn
	      (company-coq-mode t)
	      (rainbow-delimiters-mode t))))

(elpy-enable) ; mostly for running unit tests the lazy way
(set-variable 'python-shell-interpreter "python3")

(let ((opam-share (ignore-errors (car (process-lines "opam" "config" "var" "share")))))
      (when (and opam-share (file-directory-p opam-share))
       ;; Register Merlin
       (add-to-list 'load-path (expand-file-name "emacs/site-lisp" opam-share))
       (autoload 'merlin-mode "merlin" nil t nil)
       ;; Automatically start it in OCaml buffers
       (add-hook 'tuareg-mode-hook 'merlin-mode t)
       (add-hook 'caml-mode-hook 'merlin-mode t)
       ;; Use opam switch to lookup ocamlmerlin binary
       (setq merlin-command 'opam)))
       
;; use dune utop
(setq utop-command "opam config exec -- dune utop . -- -emacs")

(autoload 'utop-minor-mode "utop" "Minor mode for utop" t)
(add-hook 'tuareg-mode-hook 'utop-minor-mode)

   (setq multi-term-program "/run/current-system/sw/bin/bash")

(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program (if (eq system-type 'darwin)
                                     "open"
				     "brave"))
(setq package-install-upgrade-built-in t)

(display-battery-mode)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("551629d1e63bb66423dd80b3ec2d1a67611d1fa570e7238201e65b25a3b3834f" "1a6d120936f9df3f44953124dbf9e56b399e021702ca7d1844e6c5e1658b692b" default))
 '(package-selected-packages
   '(seq lua-mode fzf cargo magit rg change-inner racer unicode-fonts undo-tree tuareg tao-theme rainbow-delimiters plan9-theme pinentry paredit org-bullets markdown-mode visual-regexp ivy flycheck exec-path-from-shell auto-complete elpy moe-theme slime)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

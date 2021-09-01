(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-engine 'luatex)
 '(package-selected-packages '(org-attach-screenshot))
 '(safe-local-variable-values
   '((eval let
           ((unimath-topdir
             (expand-file-name
              (locate-dominating-file buffer-file-name "UniMath"))))
           (setq fill-column 100)
           (make-local-variable 'coq-use-project-file)
           (setq coq-use-project-file nil)
           (make-local-variable 'coq-prog-args)
           (setq coq-prog-args
                 `("-quiet" "-emacs" "-noinit" "-indices-matter" "-type-in-type" "-w" "-notation-overridden" "-Q" ,(concat unimath-topdir "UniMath")
                   "UniMath"))
           (make-local-variable 'coq-prog-name)
           (setq coq-prog-name
                 (concat unimath-topdir "sub/coq/bin/coqtop"))
           (make-local-variable 'before-save-hook)
           (add-hook 'before-save-hook 'delete-trailing-whitespace)
           (modify-syntax-entry 39 "w")
           (modify-syntax-entry 95 "w")
           (if
               (not
                (memq 'agda-input features))
               (load
                (concat unimath-topdir "emacs/agda/agda-input")))
           (if
               (not
                (member
                 '("chimney" "╝")
                 agda-input-user-translations))
               (progn
                 (setq agda-input-user-translations
                       (cons
                        '("chimney" "╝")
                        agda-input-user-translations))
                 (setq agda-input-user-translations
                       (cons
                        '("==>" "⟹")
                        agda-input-user-translations))
                 (agda-input-setup)))
           (set-input-method "Agda"))
     (eval let
           (unimath-topdir
            (expand-file-name
             (locate-dominating-file buffer-file-name "UniMath")))
           (setq fill-column 100)
           (make-local-variable 'coq-use-project-file)
           (setq coq-use-project-file nil)
           (make-local-variable 'coq-prog-args)
           (setq coq-prog-args
                 `("-quiet" "-emacs" "-noinit" "-indices-matter" "-type-in-type" "-w" "-notation-overridden" "-Q" ,(concat unimath-topdir "UniMath")
                   "UniMath"))
           (make-local-variable 'coq-prog-name)
           (setq coq-prog-name
                 (concat unimath-topdir "sub/coq/bin/coqtop"))
           (make-local-variable 'before-save-hook)
           (add-hook 'before-save-hook 'delete-trailing-whitespace)
           (modify-syntax-entry 39 "w")
           (modify-syntax-entry 95 "w")
           (if
               (not
                (memq 'agda-input features))
               (load
                (concat unimath-topdir "emacs/agda/agda-input")))
           (if
               (not
                (member
                 '("chimney" "╝")
                 agda-input-user-translations))
               (progn
                 (setq agda-input-user-translations
                       (cons
                        '("chimney" "╝")
                        agda-input-user-translations))
                 (setq agda-input-user-translations
                       (cons
                        '("==>" "⟹")
                        agda-input-user-translations))
                 (agda-input-setup)))
           (set-input-method "Agda")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

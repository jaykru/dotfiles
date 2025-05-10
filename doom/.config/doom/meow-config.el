(require 'meow)
(require 'transient)

(meow-global-mode 1)

(transient-define-prefix meow-goto-menu ()
  "Goto"
  ["goto"
   ("g" "Beginning of buffer" beginning-of-buffer)
   ("e" "End of buffer" end-of-buffer)
   ("h" "Beginning of line" beginning-of-line)
   ("l" "End of line" end-of-line)
   ("b" "Buffer" consult-buffer)
   ("k" "Page up" meow-page-up)
   ("j" "Page down" meow-page-down)
   ("d" "Definition" xref-find-definitions)
   ("." "Jump forward" xref-go-forward)
   (","  "Jump backward" xref-go-back)
   ("SPC" "jump" avy-goto-char-timer)])

(transient-define-prefix meow-match-menu ()
  "Match"
  ["match"
   ("i" "select inside object" meow-inner-of-thing)
   ("a" "select around object" meow-bounds-of-thing)])

(transient-define-prefix meow-window-menu ()
  "Window"
  ["Window"
   ("w" "go to next window" other-window)
   ("'" "vertical split" split-window-right)
   ("-" "horizontal split" split-window-below)
   ("q" "kill current window" delete-window)
   ("m" "kill all windows but current" delete-other-windows)

   ("h" "go left" windmove-left)
   ("j" "go down" windmove-down)
   ("k" "go up" windmove-up)
   ("l" "go right" windmove-right)

   ("H" "go left" windmove-swap-states-left)
   ("J" "go down" windmove-swap-states-down)
   ("K" "go up" windmove-swap-states-up)
   ("L" "go right" windmove-swap-states-right)])

(global-unset-key (kbd "C-c w"))
(global-set-key (kbd "C-c w") 'meow-window-menu)

(defun meow-delete-or-kill ()
  (interactive)
  (if (region-active-p)
    (meow-kill)
    (meow-delete)))

(meow-define-keys
    'normal
  '("d" . meow-delete-or-kill)
  '("s" . isearch-forward)
  '("g" . meow-goto-menu)
  '("m" . meow-match-menu))

(setq symex--user-evil-keyspec
      '(("j" . symex-go-up)
        ("k" . symex-go-down)
        ("C-j" . symex-climb-branch)
        ("C-k" . symex-descend-branch)
        ("M-j" . symex-goto-highest)
        ("M-k" . symex-goto-lowest)))
; (symex-initialize)
(global-set-key (kbd "C-c ;") 'symex-mode-interface)

; FIXME: remove when meow config is ready
(meow-global-mode -1)

(set-variable 'avy-all-windows t)

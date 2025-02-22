;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Jay Kruer"
      user-mail-address "j@dank.systems")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
(setq doom-font "Berkeley Mono")
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(global-set-key (kbd "C-x b") 'switch-to-buffer)
(require 'agda-input)
(set-input-method "Agda")
(add-hook 'agda2-mode-hook
          (local-set-key (kbd "C-c C-g") 'agda2-next-goal) )
(set-variable 'notmuch-search-oldest-first nil)
;; (use-package! chatgpt
;;   (chatgpt :type git :host github :repo "emacs-openai/chatgpt"))
(setq doom-unreal-buffer-functions '(minibufferp))
(set-variable '+popup-default-parameters
              (assq-delete-all 'no-other-window +popup-default-parameters))
(remove-hook '+popup-buffer-mode-hook #'+popup-set-modeline-on-enable-h) ; show modeline for popup windows.

(defvar gptel-api-key-file (expand-file-name "~/.gptel-api-key"))

(defun gptel-read-api-key ()
  (with-temp-buffer
    (insert-file-contents gptel-api-key-file)
    (goto-char (point-min))
    (while (re-search-forward "[\n\t ]+$" nil t)
      (replace-match ""))
    (buffer-string)))

(setq gptel-model 'gemini-2.0-flash-thinking-exp
      gptel-backend (gptel-make-gemini
                      "Gemini"
                      :key (gptel-read-api-key)
                      :stream t))

(global-set-key (kbd "C-c g m") 'gptel-menu)
(global-set-key (kbd "C-c g c") 'gptel)
(global-set-key (kbd "C-c g r") 'gptel-rewrite)
(global-set-key (kbd "C-c g s") 'gptel-send)

(set-variable 'gptel-directives
              '((default     . "You are a large language model living in Emacs and a helpful assistant. Do not be sycophantic.")
                (programming . "You are a large language model and a careful programmer. Provide code and only code as output without any additional text, prompt or note.")
                (writing     . "You are a large language model and a writing assistant. Respond concisely.")
                (chat        . "You are a large language model and a conversation partner. Do not be sycophantic.")))

;; asks gptel a question about the current buffer; response will appear in a separate
;; buffer
(defvar gptel-ask--history nil)
(defun gptel-ask ()
  (interactive)
  (let* ((context (if (region-active-p)
                      (buffer-substring (region-beginning) (region-end))
                    (buffer-string)))
         (prompt (read-string "Ask gptel: " nil gptel-ask--history nil))
        (prompt-with-context (concat "Here's the context: "
                                     context
                                     "\n"
                                     prompt)))
    (gptel-request
        prompt-with-context
      ;; :buffer resp-buffer
      :system "Be concise, but not at the expanse of answering the query completely. When responding with code, use markdown to format your answer. If the user hasn't asked a question, just explain the lines of code or evaluate it."
      :callback (lambda (response info)
                  (if (not response)
                      (message "gptel-lookup failed with message: %s" (plist-get info :status))
                    (with-current-buffer (get-buffer-create "*gptel answer*")
                      (let ((inhibit-read-only t))
                        (markdown-mode)
                        (erase-buffer)
                        (insert response))
                      (display-buffer (current-buffer)
                                      `((display-buffer-in-side-window)
                                        (side . bottom)
                                        (window-height . ,#'fit-window-to-buffer)))))))))

(global-set-key (kbd "C-c g q") 'gptel-ask)

(set-variable 'gptel-max-tokens 4096)
;;  in vterm-mode, bind C-x C-j to 'vterm-copy-mode
(add-hook 'vterm-mode-hook
          (lambda ()
            (define-key vterm-mode-map (kbd "C-x j") 'vterm-copy-mode)))

;; also need a hook for vterm-copy-mode to invoke vterm-copy-mode-done
(add-hook 'vterm-copy-mode-hook
          (lambda ()
            (define-key vterm-copy-mode-map (kbd "C-x j") 'vterm-copy-mode-done)))

;;; magit customizations
(transient-append-suffix 'magit-submodule "u" ; add it after the "update submodule one"
  '("a" "Update/init all submodules recursively" (lambda ()
                       (interactive)
                       (magit-run-git "submodule" "update" "--init" "--recursive"))))

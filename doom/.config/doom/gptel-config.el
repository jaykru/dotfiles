;; gptel configuration
(require 'gptel)

(global-set-key (kbd "C-c g c") 'gptel)
(global-set-key (kbd "C-c g r") 'gptel-rewrite)
(global-set-key (kbd "C-c g s") 'gptel-send)
(global-set-key (kbd "C-c g m") 'gptel-menu)

(setq gptel-directives
      (let ((common " If tools are made available to you, use any and all of them required to completely answer the question or accomplish the task. Do not be lazy. Do not ask the user to do anything for you that can already be accomplished by the tools. If the tools are insufficient for the task, say so and request that a new tool be added. Be decisive and do not equivocate. Do not explain or break down code or mathematics in responses unless specifically requested to do so. If you have the current windows tool available, use it to get context into what the user is talking about if the query is otherwise unclear. When the user talks about 'what they're looking at', it might be in reference to visible Emacs buffers. If the user asks you to accomplish something that can be done with a shell command, and it is likely that the user would like to supervise your actions, prefer using the vterm tool. If the user does not specify which VTerm buffer to use, use your best guess, but you may only use visible vterm buffers.")
            (add-common (lambda (directive)
                          (let ((name (car directive))
                                (prompt (cdr directive)))
                            `(,name . ,(string-join `(,prompt ,common)))
                            )
                          )))
        (mapcar add-common
                '((default . "You are a large language model living in Emacs and a helpful assistant. Respond concisely.")
                  (programming . "You are a large language model and a careful programmer. Provide code and only code as output without any additional text, prompt or note. You are expressly forbidden from the use of Markdown or other markup to wrap any code output."))
                )))

(defvar gemini-api-key-file (expand-file-name "~/.gemini-api-key"))
(defvar deepseek-api-key-file (expand-file-name "~/.deepseek-api-key"))
(defvar brave-search-api-key-file (expand-file-name "~/.brave-search-api-key"))
(defvar litellm-api-key-file (expand-file-name "~/.litellm-api-key"))
(defvar litellm-hostname-file (expand-file-name "~/.litellm-hostname"))

(defun read-api-key (api-key-file)
  "Read API key from API-KEY-FILE, removing trailing whitespace."
  (when (file-exists-p api-key-file)
    (with-temp-buffer
      (insert-file-contents api-key-file)
      (goto-char (point-min))
      (while (re-search-forward "[\n\t ]+$" nil t)
        (replace-match ""))
      (buffer-string))))

;; Conditionally configure DeepSeek
(if (file-exists-p deepseek-api-key-file)
    (progn
      (gptel-make-deepseek "DeepSeek"
        :stream t
        :key (read-api-key deepseek-api-key-file))
      ;; Set default model only if DeepSeek is configured)
  (message "DeepSeek API key file not found: %s. DeepSeek provider not configured." deepseek-api-key-file)))
;; Conditionally configure Gemini
(if (file-exists-p gemini-api-key-file)
    (progn
      (gptel-make-gemini
          "Gemini"
        :key (read-api-key gemini-api-key-file)
        :stream t)
      (setq gptel-model 'gemini))
  (message "Gemini API key file not found: %s. Gemini provider not configured." gemini-api-key-file))

(if (and (file-exists-p litellm-hostname-file)
         (file-exists-p litellm-api-key-file))
    (setq
     gptel-model   'azure/gpt-4.1
     gptel-backend (gptel-make-openai "tt"          ;Any name
                     :stream t                             ;Stream responses
                     :protocol "https"
                     :endpoint "/chat/completions"
                     :host (read-api-key litellm-hostname-file)
                     :models '((azure/gpt-4.1
                                :capabilities (media json url tool)
                                :mime-types
                                ("image/jpeg" "image/png" "image/gif" "image/webp"))
                               (gemini/gemini-2.5-pro-preview-03-25
                                :capabilities (media json url tool)
                                :mime-types
                                ("image/jpeg" "image/png" "image/gif" "image/webp")))
                     :key (read-api-key litellm-api-key-file)))
  (message "LiteLLM hostname or API key files not found: %s %s. LiteLLM provider not configured." litellm-hostname-file litellm-api-key-file))

(setq gptel-use-tools t)
(setq gptel-tools nil) ; clear tools for reloading

(defmacro define-tool (&rest toolspec)
  `(add-to-list 'gptel-tools
    (gptel-make-tool
     ,@toolspec)
    ))

(define-tool
  :name "create_vterm"
  :description "Create a new VTerm buffer and make it visible."
  :function (lambda ()
              (let ((current-prefix-arg '(4)))
                (call-interactively #'vterm)))
  :args '()
  :category "emacs")

(define-tool
  :name "send_to_vterm"
  :description "Input any text into an active VTerm buffer."
  :function (lambda (buffer input)
              (with-current-buffer buffer
                ; only operate in vterm buffers
                (cl-assert (equal major-mode 'vterm-mode))
                ; ensure vterm copy mode is disabled
                (vterm--exit-copy-mode)
                ; ensure the buffer is visible before running any commands.
                (unless (get-buffer-window buffer)
                  (display-buffer buffer))
                (vterm-insert input)
                (select-window (get-buffer-window buffer))))
  :args (list '(:name "buffer"
                :type string
                :description "The VTerm buffer to insert text into.")
              '(:name "input"
                :type string
                :description "The text you want to insert into the VTerm buffer. Do not pass a newline."))
  :category "emacs")

(define-tool
  :name "find_file"
  :description "Navigate to a file in Emacs, either opening its existing buffer or creating a new buffer. You may use this tool to visit existing files or to create new ones."
  :function (lambda (path)
              (find-file path))
  :args (list '(:name "path"
                :type string
                :description "Path to the file you wish to visit"))
  :category "emacs")

(define-tool
  :name "read_file"
  :function (lambda (filepath)
              (with-temp-buffer
                (insert-file-contents (expand-file-name filepath))
                (buffer-string)))

  :description "Read and display the contents of a file"
  :args (list '(:name "filepath"
                :type string
                :description "Path to the file to read. Supports relative paths and ~."))
  :category "filesystem")


(define-tool
  :name "list_directory"
  :function (lambda (directory)
              (mapconcat #'identity
                         (directory-files directory)
                         "\n"))

  :description "List the contents of a given directory"
  :args (list '(:name "directory"
                :type string
                :description "The path to the directory to list"))
  :category "filesystem")

(define-tool
  :name "make_directory"
  :function (lambda (parent name)
              (condition-case nil
                  (progn
                    (make-directory (expand-file-name name parent) t)
                    (format "Directory %s created/verified in %s" name parent))
                (error (format "Error creating directory %s in %s" name parent))))

  :description "Create a new directory with the given name in the specified parent directory"
  :args (list '(:name "parent"
                :type string
                :description "The parent directory where the new directory should be created, e.g. /tmp")
              '(:name "name"
                :type string
                :description "The name of the new directory to create, e.g. testdir"))
  :category "filesystem")

(define-tool
  :name "echo_message"
  :function (lambda (text)
              (message "%s" text)
              (format "Message sent: %s" text))

  :description "Send a message to the *Messages* buffer"
  :args (list '(:name "text"
                :type string
                :description "The text to send to the messages buffer"))
  :category "emacs")

(define-tool
  :name "read_url"
  :function (lambda (url)
              (with-current-buffer (url-retrieve-synchronously url)
                (goto-char (point-min))
                (forward-paragraph)
                (let ((dom (libxml-parse-html-region (point) (point-max))))
                  (run-at-time 0 nil #'kill-buffer (current-buffer))
                  (with-temp-buffer
                    (shr-insert-document dom)
                    (buffer-substring-no-properties (point-min) (point-max))))))

  :description "Fetch and read the contents of a URL"
  :args (list '(:name "url"
                :type string
                :description "The URL to read"))
  :category "web")

(define-tool
  :name "read_buffer"
  :function (lambda (buffer)
              (unless (buffer-live-p (get-buffer buffer))
                (error "Error: buffer %s is not live." buffer))
              (with-current-buffer buffer
                (buffer-substring-no-properties (point-min) (point-max))))

  :description "Return the contents of an Emacs buffer"
  :args (list '(:name "buffer"
                :type string
                :description "The name of the buffer whose contents are to be retrieved"))
  :category "emacs")

(define-tool
  :name "get_buffer_path"
  :function (lambda (buffer)
              (unless (buffer-live-p (get-buffer buffer))
                (error "Error: buffer %s is not live." buffer))
              (with-current-buffer buffer
                (buffer-file-name)))

  :description "Return the full fs path of an Emacs buffer"
  :args (list '(:name "buffer"
                :type string
                :description "The name of the buffer whose contents are to be retrieved"))
  :category "emacs")

(define-tool
  :name "append_to_buffer"
  :function (lambda (buffer text)
              (with-current-buffer (get-buffer-create buffer)
                (save-excursion
                  (goto-char (point-max))
                  (insert text)))
              (format "Appended text to buffer %s" buffer))

  :description "Append text to an Emacs buffer. If the buffer does not exist, it will be created."
  :args (list '(:name "buffer"
                :type string
                :description "The name of the buffer to append text to.")
              '(:name "text"
                :type string
                :description "The text to append to the buffer."))
  :category "emacs")

(define-tool
  :name "list_buffers"

  :function (lambda ()
              (mapconcat #'buffer-name (buffer-list) ", "))
  :description "List current Emacs buffers"
  :args '()
  :category "emacs")

(define-tool
  :name "list_visible_buffers"
  :function (lambda ()
              (mapconcat #'(lambda (w)
                             (buffer-name (window-buffer w)))
                         (window-list)
                         ", "))
  :description "List buffers currently visible in the Emacs session"
  :args '()
  :category "emacs")

(define-tool
  :name "subst_in_buffer"
  :function (lambda (buffer pattern replacement-pattern)
              (with-current-buffer (get-buffer-create buffer)
                (goto-char 0)
                (save-excursion
                  (while (re-search-forward pattern nil t)
                    (replace-match replacement-pattern nil nil)))))

  :args (list '(:name "buffer"
                :type string
                :description "The name of the buffer to append text to.")
              '(:name "pattern"
                :type string
                :description "The Emacs regexp pattern to match.")
              '(:name "replacement-pattern"
                :type string
                :description "The replacement pattern by which to replace matches."))
  :description "Applies a substitution to a buffer. The substitution is applied over the
entire buffer beginning with the first character. The pattern is
specified in Emacs regular expression syntax. The replacement pattern
need not be constant; it can refer to all or part of what is matched by
the pattern: '\&' refers to the entire match; '\d' where d is a number
starting from 1, stands for whatever matched the dth parenthesized
grouping in the pattern; '\#' refers to the count of replacements
already made by this command. Here is a brief summary of the syntax:
Emacs regular expressions use a combination of ordinary characters and
special constructs. Ordinary characters match themselves exactly, while
special characters ($^.*+?[\) have specific meanings. The primary
special characters and their functions are:

. matches any single character except newline * is a postfix operator
that matches the preceding expression zero or more times (greedy) +
matches the preceding expression one or more times (greedy) ? matches
the preceding expression zero or one time (greedy) *?, +?, ?? are
non-greedy variants of the above operators [...] creates a bracket
expression matching any one of the enclosed characters [^...] creates a
complemented bracket expression matching any character except those
enclosed ^ matches the empty string at the beginning of a line $ matches
the empty string at the end of a line \ quotes special characters and
introduces additional special constructs

Bracket expressions can include individual characters, character ranges
denoted by - (like [a-z]), and character classes enclosed in [: :] (like
[:alnum:]). Special rules apply when including ], -, or ^ within bracket
expressions. When in case-insensitive search, ranges should use
consistent case. The manual notes that regular expressions can be
concatenated, and that operators apply to the smallest possible
preceding expression."
  :category "emacs")

(let ((brave-search-api-key (read-api-key brave-search-api-key-file)
                            )
      (do-brave-search (lambda (query)
                         (let ((url-request-method "GET")
                               (url-request-extra-headers `(("X-Subscription-Token" . ,brave-search-api-key)))
                               (url (format "https://api.search.brave.com/res/v1/web/search?q=%s" (url-encode-url query))))
                           (with-current-buffer (url-retrieve-synchronously url)
                             (goto-char (point-min))
                             (when (re-search-forward "^$" nil 'move)
                               (let ((json-object-type 'hash-table)) ; Use hash-table for JSON parsing
                                 (json-parse-string (buffer-substring-no-properties (point) (point-max)))))))
                         )))
  (when brave-search-api-key
    (define-tool
      :name "brave_search"
      :function do-brave-search

      :description "Perform a web search using the Brave Search API"
      :args (list '(:name "query"
                    :type string
                    :description "The search query string"))
      :category "web")))

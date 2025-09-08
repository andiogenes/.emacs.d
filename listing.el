;;; listing.el --- Render current buffer as HTML page with syntax-highlighted code listing.

;; Author : arxdukalis
;;
;; This file is not part of GNU Emacs.

;;; Code:

(defcustom arx/highlight-js-path nil
  "Path to highlight.js bundle."
  :type 'string)

(defcustom arx/highlight-js-css-path nil
  "Path to highlight.js CSS table."
  :type 'string)

(defun current-buffer-listing ()
  "Create code listing for current buffer and open it."
  (interactive)
  (let* ((code-buffer-name (buffer-file-name))
         (language (read-string "Enter the name of language to higlight: " (file-name-extension code-buffer-name)))
         (code-buffer-content (buffer-substring-no-properties (point-min) (point-max)))
         (listing-file-name (concat code-buffer-name ".html")))
    (when language
      (write-region
       (format
        "<html>
<head>
<meta charset=\"UTF-8\">
<title>%s</title>
</head>
<body>
<link rel=\"stylesheet\" href=\"%s\">
<script src=\"%s\"></script>
<script>hljs.highlightAll();</script>
<pre><code class=\"language-%s\">%s</code></pre>
</body>
</html>"
        code-buffer-name arx/highlight-js-css-path arx/highlight-js-path language code-buffer-content)
       nil listing-file-name)

      ;; TODO: write crossplatform URL opener
    (shell-command (concat "open \"" listing-file-name "\"")))))

;;; dashboard.el --- Humble custom dashboard  -*- lexical-binding: t; -*-

;; Author : arxdukalis
;;
;; This file is not part of GNU Emacs.

;;; Commentary:

;; Minimal startup screen implemented in worse-is-better style
;; to cover all my needs in whatever startup screen should be.
;;
;; It is written after https://github.com/emacs-dashboard/

;;; Code:

(defgroup arx/dashboard nil
  "Custom dashboard."
  :group 'applications)

(defconst arx/dashboard-buffer-name "*dashboard*")

(defcustom arx/dashboard-unseen-university-dir "~"
  "Unseen University directory."
  :group 'arx/dashboard
  :type 'string)

(defcustom arx/dashboard-content
  '(("[u]" . "Unseen University")
    ("[e]" . ".emacs.d/init.el")
    ("[f]" . "find file")
    ("[s]" . "*scratch*"))
  "Content of dashboard."
  :group 'arx/dashboard)

(defvar arx/dashboard--content-formatted nil)
(defvar arx/dashboard--content-line-count 0)
(defvar arx/dashboard--content-max-line-width 0)

(defun arx/dashboard--content-format (lines)
  (seq-map
   (lambda (p)
     (let ((key (car p)) (descr (cdr p)))
       (concat (propertize key 'face 'bold) " - " (propertize descr 'face 'italic))))
   lines))

(defun arx/dashboard--content-estimate-line-length (line)
  (let ((key (car line)) (descr (cdr line))
        (sep-len 1) (whitesp-len 2))
    (+ (length key) (length descr) sep-len whitesp-len)))

(defun arx/dashboard--content-init-vars ()
  (setq arx/dashboard--content-formatted (arx/dashboard--content-format arx/dashboard-content)
        arx/dashboard--content-line-count (length arx/dashboard-content)
        arx/dashboard--content-max-line-width
        (seq-max (seq-map #'arx/dashboard--content-estimate-line-length arx/dashboard-content))))

(defun arx/dashboard-find-unseen-university ()
  "Find Unseen University from dashboard."
  (interactive)
  (find-file arx/dashboard-unseen-university-dir))

(defun arx/dashboard-find-emacs-init-file ()
  "Find .emacs.d/init.el from dashboard."
  (interactive)
  (find-file (format "%s/init.el" user-emacs-directory)))

(defun arx/dashboard-switch-to-scratch ()
  "Switch to *scratch* from dashboard."
  (interactive)
  (switch-to-buffer "*scratch*"))

(defvar arx/dashboard-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "u") #'arx/dashboard-find-unseen-university)
    (define-key map (kbd "e") #'arx/dashboard-find-emacs-init-file)
    (define-key map (kbd "f") #'find-file)
    (define-key map (kbd "s") #'arx/dashboard-switch-to-scratch)
    map)
  "Keymap for dashboard mode.")

(define-derived-mode arx/dashboard-mode special-mode "Dashboard"
  "Custom dashboard mode."
  :group 'arx/dashboard
  :syntax-table nil
  :abbrev-table nil
  (buffer-disable-undo)
  (line-number-mode -1)
  (display-line-numbers-mode -1)
  (setq-local revert-buffer-function (lambda (_ _) (arx/dashboard--re-display))
              cursor-type nil
              global-hl-line-mode nil))

(defun arx/dashboard--init ()
  "Initialize dashboard."
  (arx/dashboard--content-init-vars)
  (switch-to-buffer (get-buffer-create arx/dashboard-buffer-name))
  (arx/dashboard-mode))

(defun arx/dashboard--insert-horizontally-centered-string (s max-line-width)
  (let* ((window-width (window-body-width))
         (padding (max 0 (/ (- window-width max-line-width) 2)))
         (padding-str (make-string padding ? )))
    (insert (concat padding-str s "\n"))))

(defun arx/dashboard--insert-vertical-padding (line-count)
  (let* ((window-height (window-body-height))
         (padding (max 0 (/ (- window-height line-count) 2))))
    (insert (make-string padding ?\n))))

(defun arx/dashboard--display ()
  (goto-char (point-min))
  (arx/dashboard--insert-vertical-padding arx/dashboard--content-line-count)
  (seq-do
   (lambda (s) (arx/dashboard--insert-horizontally-centered-string s arx/dashboard--content-max-line-width))
   arx/dashboard--content-formatted))

(defun arx/dashboard--re-display (&optional _)
  (let ((dashboard-window (get-buffer-window arx/dashboard-buffer-name)))
    (when (and dashboard-window (not (window-minibuffer-p (frame-selected-window))))
      (with-selected-window dashboard-window
        (with-current-buffer (get-buffer-create arx/dashboard-buffer-name)
          (let ((inhibit-read-only t))
            (erase-buffer)
            (arx/dashboard--display)
            (current-buffer)))))))

(defun arx/dashboard-setup-hooks ()
  (when (< (length command-line-args) 2) ;; No file name passed
    (add-hook 'emacs-startup-hook #'arx/dashboard--init)
    (add-hook 'window-size-change-functions #'arx/dashboard--re-display 100)))

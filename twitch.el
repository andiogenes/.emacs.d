;;; twitch.el --- Twitch chat inside Emacs (via ERC)

;; Author : arxdukalis
;;
;; This file is not part of GNU Emacs.

;;; Code:

(defgroup arx/twitch nil
  "Twitch chat client."
  :group 'applications)

(defvar arx/twitch--servlets-initialized nil)
(defun arx/twitch--servlets-init ()
  (unless arx/twitch--servlets-initialized
    (defservlet twitch text/html ()
      (insert
       "<html>
         <head>
          <title>Twitch OAuth token for chat</title>
         </head>
         <body>
          <div id=\"token\"></div>
          <a href=\"/shutdown\"><button>Click here to shut down httpd server</button></a>
          <script type=\"text/javascript\">
            document.addEventListener('DOMContentLoaded', function() {
              // Remove the '#' from the hash and set it as the body content
              document.getElementById('token').textContent =
                'Your access token is: ' + window.location.hash.substring(1).split('=')[1].split('&')[0];
            });
          </script>
         <body>
        </html>"))
    (defservlet shutdown text/plain ()
      (run-at-time 1 nil (lambda () (httpd-stop)))
      (insert "Shutting server down..."))
    (setq arx/twitch--servlets-initialized t)))

(defcustom arx/twitch-client-id nil
  "Default Twitch API client ID."
  :group 'arx/twitch
  :type 'string)

(defcustom arx/twitch-nick ""
  "Twitch nick name."
  :group 'arx/twitch
  :type 'string)

(defcustom arx/twitch-access-token ""
  "Twitch access token."
  :group 'arx/twitch
  :type 'string)

(defun twitch-regenerate-token ()
  "Regenerate OAuth token to access Twitch chats."
  (interactive)

  (require 'simple-httpd)
  (let* ((client-id (or arx/twitch-client-id (read-string "Enter your client ID: ")))
         (implicit-grant-flow-uri
          (concat
           "\"https://id.twitch.tv/oauth2/authorize?response_type=token&client_id="
           client-id
           "&scope=chat:read+chat:edit"
           "&redirect_uri=http://localhost:"
           (number-to-string httpd-port)
           "/twitch\"")))

    (arx/twitch--servlets-init)
    (unless (httpd-running-p)
      (httpd-start))

    ;; TODO: write crossplatform URL opener
    (shell-command (concat "open " implicit-grant-flow-uri))))

(defvar arx/twitch--networks-alist-initialized nil)
(defun arx/twitch--init-networks-alist ()
  (unless arx/twitch--networks-alist-initialized
    (push '(twitch "-") erc-networks-alist)
    (setq arx/twitch--networks-alist-initialized t)))

(defun twitch-start-erc ()
  "Connect to Twitch IRC."
  (interactive)
  (require 'erc)
  (arx/twitch--init-networks-alist)
  (switch-to-buffer
   (erc-tls :server "irc.chat.twitch.tv"
            :port 6697
            :nick arx/twitch-nick
            :password (concat "oauth:" arx/twitch-access-token))))

;;; init.el --- My init script -*- coding: utf-8 ; lexical-binding: t -*-
;; Author: Akihiko Takahashi
;; URL:

;;; Commentary:

;;; Code:

(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

;; leaf
(eval-and-compile
  (customize-set-variable
   'package-archives '(("org" . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu" . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

(leaf macrostep
  :ensure t
  :bind (("C-c e" . macrostep-expand)))

(leaf exec-path-from-shell
  :ensure t
  :when (memq window-system '(mac ns x))
  :defun (exec-path-from-shell-initialize)
  :custom (exec-path-from-shell-variables . '("PATH" "LANG"))
  :config (exec-path-from-shell-initialize))

;;; builtin package configuration
(leaf *load-path
  :doc "add local load path directory"
  :tag "setup"
  :defun add-to-load-path
  :preface
  (defun add-to-load-path (&rest paths)
    "Add `paths' to load path."
    (dolist (path paths paths)
      (let ((default-directory
              (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path)))))
  :config
  (unless (file-directory-p (expand-file-name "site-lisp/" user-emacs-directory))
    (make-directory (expand-file-name "site-lisp/" user-emacs-directory)))
  (add-to-load-path "site-lisp"))

(leaf cus-edit
  :doc "tools for customizing Emacs and Lisp packages"
  :tag "builtin" "faces" "help"
  :custom `((custom-file . ,(locate-user-emacs-file "custom.el"))))

(leaf cus-start
  :doc "define customization properties of builtins"
  :tag "builtin" "internal"
  :custom ((debug-on-error . t)
            (ring-bell-function . 'ignore)
            (tool-bar-mode . nil)
            (scroll-bar-mode . nil)
            (menu-bar-mode . t)
            (tab-width . 4)
            (indent-tabs-mode . nil)
            (read-buffer-completion-ignore-case . t)
            (eol-mnemonic-dos . "(CRLF)")
            (eol-mnemonic-mac . "(CR)")
            (eol-mnemonic-unix . "(LF)")
            (frame-title-format . "%f"))
  :config
  (defalias 'yes-or-no-p 'y-or-n-p)
  (keyboard-translate ?\C-h ?\C-?))

(leaf minibuffer
  :doc "completion for minibuffer"
  :tag "builtin"
  :custom `((read-file-name-completion-ignore-case . t)))

(leaf startup
  :doc "process Emacs shell arguments"
  :tag "builtin"
  :custom `((inhibit-startup-screen . t)
            (inhibit-startup-message . t)
            (initial-scratch-message . "")))

(leaf simple
  :doc "basic editing commands for Emacs"
  :tag "builtin" "internal"
  :custom ((kill-ring-max . 100)
           (kill-read-only-ok . t)
           (kill-whole-line . t)
           (eval-expression-print-length . nil)
           (eval-expression-print-level . nil)
           (line-number-mode . t)
           (column-number-mode . t)))

(leaf frame
  :doc "frame or cursor setting"
  :tag "builtin"
  :custom `((blink-cursor-mode . nil))
  :config
  (set-frame-parameter nil 'fullscreen 'maximized))

(leaf face
  :doc "foreground or background color"
  :tag "builtin"
  :config
  (set-face-foreground 'font-lock-regexp-grouping-backslash "SpringGreen1")
  (set-face-foreground 'font-lock-regexp-grouping-construct "SpringGreen1"))

(leaf hl-line
  :doc "highlight current line"
  :tag "builtin"
  :custom `((global-hl-line-mode . t)))

(leaf files
  :doc "file input and output commands for Emacs"
  :tag "bultin"
  :custom `((auto-save-timeout . 15)
            (auto-save-interval . 60)
            (delete-old-versions . t)
            (delete-auto-save-files . t)
            (make-backup-files . nil)
            (auto-save-file-name-transforms . '((".*" "~/.backups" t)))
            (backup-directory-alist . '((".*" . "~/.backups")
                                        (,tramp-file-name-regexp . nil)))
            (require-final-newline . t)))

(leaf paren
  :doc "highlight matching paren"
  :tag "builtin"
  :custom ((show-paren-delay . 0.1))
  :global-minor-mode show-paren-mode)

(leaf scroll-bar
  :doc "scroll bar setting"
  :tag "builtin"
  :custom `((scroll-bar-mode . nil)))

(leaf autorevert
  :doc "revert buffers when files on disk change"
  :tag "builtin"
  :custom ((auto-revert-interval . 1))
  :global-minor-mode global-auto-revert-mode)

(leaf delsel
  :doc "delete selection if you insert"
  :tag "builtin"
  :global-minor-mode delete-selection-mode)

(leaf cua-base
  :doc "rectangle for Emacs"
  :tag "builtin"
  :config (cua-mode t)
  :custom (cua-enable-cua-keys . nil))

(leaf ediff
  :doc "ediff setting"
  :tag "builtin"
  :custom ((ediff-window-setup-function . 'ediff-setup-windows-plain)
           (ediff-split-window-function . 'split-window-horizontally)))

(leaf ido
  :doc "interactively change buffer, find file"
  :tag "builtin"
  :custom
  ((ido-mode . t)
   (ido-everywhere . t)))

(leaf bs
  :doc "display buffers"
  :tag "builtin"
  :custom ((bs-default-configuration . "all"))
  :bind (("C-x C-b" . 'bs-show)))

(leaf uniquify
  :doc "separate buffer name same filename"
  :tag "builtin"
  :custom
  (uniquify-buffer-name-style . 'post-forward-angle-brackets))

(leaf bytecomp
  :doc "compilation of Lisp code into byte code"
  :tag "builtin"
  :custom ((byte-compile-warnings . '(not cl-functions obsolete))))

(leaf org
  :doc "org mode configuration"
  :tag "builtin"
  :custom ((system-time-locale . "C")
           (org-agenda-files . '("~/Documents/tasks.org"))
           (org-todo-keywords . '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!/!)")
                                  (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)")))
           (org-todo-keyword-faces . '(("TODO" :foreground "red" :weight bold)
                                       ("NEXT" :foreground "blue" :weight bold)
                                       ("DONE" :foreground "green" :weight bold)
                                       ("WAITING" :foreground "orange" :weight bold)
                                       ("HOLD" :foreground "magenta" :weight bold)
                                       ("CANCELLED" :foreground "forest green" :weight bold)))
           (org-todo-state-tags-triggers . '(("CANCELLED" ("CANCELLED" . t))
                                             ("WAITING" ("WAITING" . t))
                                             ("HOLD" ("WAITING") ("HOLD" . t))
                                             (done ("WAITING") ("HOLD"))
                                             ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
                                             ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
                                             ("DONE" ("WAITING") ("CANCELLED") ("HOLD"))))
           (org-log-done . 'time)
           (org-log-into-drawer . "LOGBOOK")
           (org-enforce-todo-dependencies . t)
           (org-clock-history-length . 36)
           (org-drawers . '("PROPERTIES" "LOGBOOK"))
           (org-clock-out-remove-zero-time-clocks . t)
           (org-clock-persist . t)
           (org-startup-truncated . nil) ; 起動時に折り返す
           (org-capture-templates . '(("t" "Task" entry (file+headline "~/Documents/tasks.org" "Tasks")
                                       "* TODO %?\n  %i  %T")
                                      ("n" "note" entry (file+headline "~/Documents/notes.org" "Notes")
                                       "* %?\n  %i  %T")))
           (org-startup-folded . 'content))
  :config
  (org-babel-do-load-languages 'org-babel-load-languages '((python . t)))
  :defer-config
  (leaf ox-md :require t) ;org-exportで md を表示
  :bind (("C-c c" . org-capture)
         ("C-c a" . org-agenda)))

(leaf sh-script
  :doc "shell script indent"
  :tag "builtin" "shell"
  :custom ((sh-basic-offset . 2)
           (sh-indentation . 2)))

(leaf wdired
  :doc "writable dired"
  :tag "builtin" "dired"
  :require t
  :bind (dired-mode-map ("r" . wdired-change-to-wdired-mode))
  :custom (wdired-allow-to-change-permissions . t)
  )

(leaf *language
  :config (set-language-environment 'Japanese)
  (prefer-coding-system 'utf-8))

(leaf *delete-file-if-no-contents
  :preface
  (defun my:delete-file-if-no-contents ()
    "ファイルサイズが 0 ならファイルとバッファを削除する"
    (when (and (buffer-file-name (current-buffer))
               (= (point-min) (point-max)))
      (when (yes-or-no-p "Delete file? ")
        (delete-file (buffer-file-name (current-buffer)))
        (kill-buffer (current-buffer)))))
  :hook
  (after-save-hook . my:delete-file-if-no-contents))

(leaf *auto-backup-after-save
  :preface
  (defvar abas:auto-backup-directory (expand-file-name "~/.backups/") "バックアップ先ディレクトリ")
  (defvar abas:auto-backup-time-format "%Y%m%d%H%M%S" "バックアップファイルにつける時間のフォーマット")
  (defvar abas:auto-backup-ignore-regex "\\.log$\\|/\\.backups/\\|/junk/" "バックアップを取らないファイルの正規表現")
  (defun my:auto-backup-after-save ()
    "保存後にバックアップを特定のディレクトリに保存する"
    (interactive)
    (unless (file-directory-p abas:auto-backup-directory)
      (make-directory abas:auto-backup-directory))
    (let* ((fpath (buffer-file-name (current-buffer)))
           (extension (if fpath
                          (file-name-extension (buffer-file-name (current-buffer)))
                        "")))
      (if (and fpath
               (not (string-match abas:auto-backup-ignore-regex fpath)))
          (copy-file fpath
                     (format "%s/%s_%s%s"
                             abas:auto-backup-directory
                             (replace-regexp-in-string "/" "!"
                                                       (file-name-sans-extension fpath))
                             (format-time-string abas:auto-backup-time-format)
                             (if extension
                                 (format ".%s" extension)
                               ""))
                     nil t t t))))
  :hook
  (after-save-hook . my:auto-backup-after-save))

(leaf *default-keybind
  :bind (("M-+" . text-scale-increase)
         ("M--" . text-scale-decrease)
         ("M-g" . 'goto-line)
         ("<f1>" . 'help-for-help))
  :bind* (("C-t" . 'other-window)))

;; mac os
(leaf *os-setting-for-mac
  :tag "os" "mac"
  :if (eq system-type 'darwin)
  :config
  (leaf *font-for-mac
    :doc "font and font size"
    :tag "font" "mac"
    :custom ((face-font-rescale-alist . '((".*Cica" . 1.2))))
    :config
    (set-fontset-font t 'japanese-jisx0208 "Cica"))

  (leaf ucs-normalize
    :require t
    :defvar (mac-pass-control-to-system
             ns-command-modifier
             ns-alternate-modifier)
    :custom ((set-file-name-coding-system . 'utf-8-hfs)
             (locale-coding-system . 'utf-8-hfs)
             (ns-command-modifier . 'meta)
             (ns-alternate-modifier . 'super)))

  (leaf *mac-dired-open-application
    :doc "open file with Application GUI"
    :defun deferred:process
    :init
    (leaf deferred
      :require t
      :ensure t)
    :preface
    (defun my:dired-open-app ()
      (interactive)
      (deferred:process "open" (dired-get-filename)))
    :hook (dired-mode-hook . (lambda () (define-key dired-mode-map "z" 'my:dired-open-app)))))

;; windows
(leaf *os-setting-for-windows
  :tag "os" "windows"
  :if (eq system-type 'windows-nt)
  :config
  (leaf *win-open-app
    :defun dired-get-file w32-shell-execute
    :init
    (defun my:dired-winstart ()
      "dired モードから windows の関連アプリケーションで開く"
      (interactive)
      (if (eq major-mode 'dired-mode)
          (let ((fname (dired-get-file)))
            (w32-shell-execute "open" fname))))
    :hook ((dired-mode-hook . (lambda () (define-key dired-mode-map "z" 'my:dired-winstart))))))

;; Linux
(leaf *os-setting-for-linux
  :tag "os" "linux"
  :if (eq system-type 'darwin)
  :config
  (leaf *font-for-linux
    :doc "font and font size"
    :tag "font" "linux"
    :custom ((face-font-rescale-alist . '((".*Cica" . 1.2))))
    :config
    (set-fontset-font t 'japanese-jisx0208 "Cica")))

;; フォント確認用
;; abcdefghijklmnopqrstuvwxyz
;; ABCDEFGHIJKLMNOPQRSTUVWXYZ
;; 1234567890-^\@[;:],./\
;; !"#$%&'() =~|`{+*}<>?_
;;
;; あいうえおかきくけこさしすせそ
;; たちつてとなにぬねのはひふへほ
;; まみむめもやゆよらりるれろわをん
;; がぎぐげござじずぜぞだぢづでど
;; ばびぶべぼぱぴぷぺぽ

;; 壱弐参肆吾陸漆捌玖拾廿卅
;; 12345678901234567890
;; ａｂｃｄｅＡＢＣＤＥ
;;
;; +ーーーーーーーーーーーーーーーーーーーーーー+
;; |　　　　　　　　　　罫線                    |
;; +--------------------------------------------+
;;

;;; elpa package
(leaf doom-themes
  :ensure t
  :require t
  :defun (
          doom-themes-visual-bell-config
          doom-themes-neotree-config
          doom-themes-org-config)
  :config
  (load-theme 'doom-dracula t))

(leaf *mode-line
  :config
  (leaf moody
    :ensure t
    :require t
    :config
    (leaf *moody-config-mac
      :when (eq system-type 'darwin)
      :custom (moody-slant-function . 'moody-slant-apple-rgb))
    (moody-replace-mode-line-buffer-identification)
    (moody-replace-vc-mode)
    :custom
    (x-underline-at-descent-line . t))

  (leaf minions
    :ensure t
    :defun minions-mode
    :custom (minions-mode-line-lighter . "[+]")
    :config (minions-mode)))

;; (leaf doom-modeline
;;   :ensure t
;;   :require t
;;   :hook (after-init-hook . doom-modeline-mode)
;;   :custom
;;   (doom-modeline-bar-width . 3)
;;   (doom-modeline-height . 25)
;;   (doom-modeline-major-mode-color-icon . t)
;;   (doom-modeline-minor-modes . t)
;;   (doom-modeline-github . nil)
;;   (doom-modeline-mu4e . nil)
;;   (doom-modeline-irc . nil))

;; (leaf material-theme
;;   :doc "material theme"
;;   :tag "theme"
;;   :ensure t
;;   :require t
;;   :config (load-theme 'material t))

(leaf japanese-holidays
  :doc "highlight japanese holiday"
  :tag "calendar" "elpa"
  :ensure t
  :defvar calendar-holidays japanese-holidays
  :after calendar
  :require t
  :config
  (setq calendar-holidays
        (append japanese-holidays holiday-local-holidays holiday-other-holidays))
  :custom
  (calendar-mark-holidays-flag . t)
  (japanese-holiday-weekend . '(0 6))
  (japanese-holiday-weekend-marker . '(holiday nil nil nil nil nil japanese-holiday-saturday))
  :hook
  (calendar-today-visible-hook . japanese-holiday-mark-weekend)
  (calendar-today-invisible-hook . japanese-holiday-mark-weekend)
  (calendar-today-visible-hook . calendar-mark-today))

(leaf undo-tree
  :doc "visualize undo tree"
  :tag "undo" "elpa"
  :ensure t
  :leaf-defer nil
  :global-minor-mode global-undo-tree-mode
  :custom (undo-tree-auto-save-history . nil))

(leaf open-junk-file
  :doc "make junk file to test"
  :tag "coding" "elpa"
  :ensure t
  :custom `((open-junk-file-format . ,(locate-user-emacs-file
                                      "junk/%Y-%m/%d-%H%M%S.")))
  :bind (("C-x C-z" . open-junk-file)))

(leaf auto-async-byte-compile nil t
  :doc "automatic byte compile for .el file"
  :tag "coding" "lisp" "elpa"
  :ensure t
  :custom ((auto-async-byte-compile-exclude-files-regexp . "/junk/\\|/elpa/$"))
  :hook
  (emacs-lisp-mode-hook . enable-auto-async-byte-compile-mode)
  (emacs-lisp-mode-hook . turn-on-eldoc-mode)
  (lisp-interaction-mode-hook . turn-on-eldoc-mode)
  (ielm-mode-hook . turn-on-eldoc-mode))

(leaf lispxmp
  :doc "Automagic emacs lisp code annotation"
  :tag "coding" "lisp" "elpa"
  :ensure t
  :require t
  :bind ((emacs-lisp-mode-map ("C-c C-d" . lispxmp))))

;;; 2022/4/5 smartparens に統合
;; (leaf paredit
;;   :ensure t
;;   :hook
;;   (emacs-lisp-mode-hook . enable-paredit-mode)
;;   (lisp-interaction-mode-hook . enable-paredit-mode)
;;   :config
;;   (leaf paren
;;     :doc "highlight matching paren"
;;     :tag "builtin"
;;     :custom ((show-paren-delay . 0.1))
;;     :global-minor-mode show-paren-mode))

(leaf skk
  :doc "install dictionary and configuration skk"
  :tag "skk" "ddskk" "input" "elpa"
  :ensure ddskk
  :require t skk-study skk-hint
  :config
  (leaf *skk-install-dict
    :unless (file-exists-p (locate-user-emacs-file "ddskk/dict/SKK-JISYO.L"))
    :config
    (skk-get (locate-user-emacs-file "ddskk/dict/")))
  (leaf *skk-install-tutorial
    :unless (file-exists-p
             (locate-user-emacs-file "ddskk/SKK.tut"))
    :config
    (shell-command
     (format "curl https://raw.githubusercontent.com/skk-dev/ddskk/master/etc/SKK.tut -o %s"
             (locate-user-emacs-file "ddskk/SKK.tut"))))
  :custom `((skk-large-jisyo . ,(locate-user-emacs-file "ddskk/dict/SKK-JISYO.L"))
            (skk-jisyo . ,(locate-user-emacs-file ".skk-jisyo"))
            (skk-backup-jisyo . ,(locate-user-emacs-file ".skk-jisyo.BAK"))
            (skk-record-file . ,(locate-user-emacs-file ".skk-record"))
            (skk-egg-like-newline . t)
            (skk-preload . t)
            (skk-tut-file . ,(locate-user-emacs-file "ddskk/SKK.tut")))
  :bind (("C-x j" . skk-mode)))

(leaf migemo
  :doc "migemo"
  :tag "search" "elpa"
  :when (executable-find "cmigemo")
  :ensure t
  :custom
  `((migemo-command . ,(executable-find "cmigemo"))
    (migemo-options . '("-q" "--emacs"))
    (migemo-user-dictionary . nil)
    (migemo-regex-dictionary . nil)
    (migemo-coding-system . 'utf-8-unix))
  :config
  (leaf *migemo-dictionary-mac
    :when (eq system-type 'darwin)
    :custom (migemo-dictionary . "/usr/local/share/migemo/utf-8/migemo-dict"))
  (leaf *migemo-dictionary-ubuntu
    :when (eq system-type 'gnu/linux)
    :custom (migemo-dictionary . "/usr/share/cmigemo/utf-8/migemo-dict"))
  :hook
  (after-init-hook . migemo-init))

(leaf wgrep
  :ensure t
  :custom
  (wgrep-change-readonly-file . t)
  (wgrep-enable-key . "e"))

(leaf sed-mode
  :doc "major mode for sed"
  :tag "elpa" "sed" "shell"
  :ensure t
  )

(leaf whitespace
  :ensure t
  :commands whitespace-mode
  :bind ("C-c W" . whitespace-cleanup)
  :custom ((whitespace-style . '(face
                                trailing
                                tabs
                                spaces
                                empty
                                space-mark
                                tab-mark))
           (whitespace-display-mappings . '((space-mark ?\u0020 [?\u0020]) ; 半角スペースはそのまま表示
                                            (space-mark ?\u3000 [?\u3000]) ; 全角スペースはそのまま表示
                                            (tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])))
           (whitespace-space-regexp . "\\(\u3000+\\)")
           (whitespace-global-modes . '(emacs-lisp-mode shell-script-mode sh-mode python-mode org-mode))
           (global-whitespace-mode . t))
  :config
  (set-face-attribute 'whitespace-trailing nil
                      :background "Black"
                      :foreground "DeepPink"
                      :underline t)
  (set-face-attribute 'whitespace-tab nil
                      :background "Black"
                      :foreground "LightSkyBlue"
                      :underline t)
  (set-face-attribute 'whitespace-space nil
                      :background "Black"
                      :foreground "GreenYellow"
                      :weight 'bold)
  (set-face-attribute 'whitespace-empty nil
                      :background "Black"))

(leaf yaml-mode
  :doc "yaml mode"
  :tag "document" "elpa"
  :ensure t
  :leaf-defer t
  :mode (("\\.yaml\\'" . yaml-mode)
         ("\\.yml\\'" . yaml-mode)))

(leaf csv-mode
  :doc "csv mode"
  :tag "document" "elpa"
  :ensure t
  :mode (("\\.csv\\'" . csv-mode )
         ("\\.CSV\\'" . csv-mode)))

(leaf magit
  :doc "git for emacs"
  :tag "code" "elpa"
  :ensure t
  :bind (("C-x g" . magit-status)))

(leaf visual-regexp-steroids
  :doc "visualize match point regular expression"
  :tag "search" "elpa"
  :ensure t
  :config
  (leaf *visual-regexp-steroids-python
    :when (executable-find "python")
    :custom ((vr/engine . 'python)))
  (leaf *visual-regexp-steroids-no-python
    :when (not (executable-find "python"))
    :custom ((vr/engine . 'pcre2el)))
  :bind (("C-M-s" . vr/isearch-forward)
         ("C-M-r" . vr/isearch-backward)
         ("M-%" . vr/query-replace)))

(leaf viewer
  :doc "viewer mode"
  :tag "document" "elpa"
  :ensure t
  :require t
  :defun (viewer-stay-in-setup
          viewer-change-modeline-color-setup
          viewer-aggressive-setup)
  :config
  (viewer-stay-in-setup)
  (viewer-change-modeline-color-setup)
  :custom ((viewer-modeline-color-unwritable . "tomato")
           (viewer-modeline-color-view . "orange")))

(leaf view
  :doc "viewer mode configuration"
  :tag "document" "view" "elpa"
  :ensure t
  :require t
  :bind (:view-mode-map
         ("N" . View-search-last-regexp-backward)
         ("?" . View-search-regexp-backward)
         ("G" . View-goto-line-last)
         ("b" . View-scroll-page-backward)
         ("f" . View-scroll-line-forward)
         ("k" . View-scroll-line-backward)
         ("j" . View-scroll-line-forward)))

(leaf yatex
  :doc "yatex mode configuration"
  :tag "document" "elpa"
  :ensure t
  ;; (leaf *yatex-server
  ;;   :config
  ;;   :when (eq system-type 'darwin)
  ;;   :config
  ;;   (server-start))
  :commands (yatex-mode)
  :mode (("\\.tex\\'" . yatex-mode)
         ("\\.ltx\\'" . yatex-mode)
         ("\\.cls\\'" . yatex-mode)
         ("\\.sty\\'" . yatex-mode)
         ("\\.clo\\'" . yatex-mode)
         ("\\.bbl\\'" . yatex-mode))
  :bind (("C-c C-t" . YaTeX-typeset-menu))
  :custom
  (YaTeX-inhibit-prefix-letter . t)
  (YaTeX-kanji-code . nil)
  (YaTeX-latex-message-code . 'utf-8)
  (YaTeX-use-font-lock . t)
  (YaTeX-use-LaTeX2e . t)
  (YaTeX-use-AMS-LaTeX . t)

  ;; ;; (dvi2-command . "evince")  ; for ubuntu
  `(tex-command . ,(if (executable-find "latexmk") "latexmk " "platex"))
  `(tex-pdfview-command . ,(cond ((eq system-type 'darwin) "open -a Skim") ; for mac
                                 ((eq system-type 'gnu/linux) "evince") ; for ubuntu
                                 ((eq system-type 'windows-nt) "") ; for windows
                                 ))
  (YaTeX-template-file . "~/.yatex-template")
  (YaTeX-close-paren-always . nil)
  (YaTeX-math-sign-alist-private . '(("Q" "mathbb{Q}" "(Q)")
                                     ("ZZ" "mathbb{Z}" "ZZ")
                                     ("R" "mathbb{R}" "R")
                                     ("C" "mathbb{C}" "C")
                                     ("N" "mathbb{N}" "N")
                                     ("Z>0" "mathbb{Z}_{>0}" "Z>0")
                                     ("F" "mathbb{F}" "F")
                                     ("Fp" "mathbb{F}_p" "F_p")))
  :defvar skk-j-mode-map
  :hook
  (yatex-mode-hook . (lambda () (outline-minor-mode t)))
  (skk-mode-hook . (lambda ()
                     (if (eq major-mode 'yatex-mode)
                         (progn
                           (define-key skk-j-mode-map (kbd "\\") 'self-insert-command)
                           (define-key skk-j-mode-map (kbd "$") 'YaTeX-insert-dollar))))))

(leaf smartparens
  :doc "Automatic insertion, wrapping and paredit-like navigation with user defined pairs"
  :tag "develop" "elpa"
  :ensure t
  :hook (after-init-hook . smartparens-global-strict-mode) ; strictモードを有効化
  :require smartparens-config
  :custom ((electric-pair-mode . nil)
           ;; (sp-base-key-bindings . 'paredit) ;キーバインドを paredit っぽく
           )
  :bind (smartparens-strict-mode-map ("M-s" . sp-splice-sexp))
  )

(leaf highlight-indent-guides
  :doc "highlight indent"
  :tag "develop" "elpa"
  :ensure t
  :blackout t
  :hook (((prog-mode-hook yaml-mode-hook) . highlight-indent-guides-mode))
  :custom (
           (highlight-indent-guides-method . 'character)
           (highlight-indent-guides-auto-enabled . t)
           (highlight-indent-guides-responsive . t)
           (highlight-indent-guides-character . ?\|)))

(leaf rainbow-delimiters
  :ensure t
  :hook
  ((prog-mode-hook . rainbow-delimiters-mode)))

(leaf mwim
  :ensure t
  :bind (("C-a" . mwim-beginning-of-code-or-line)
         ("C-e" . mwim-end-of-code-or-line)))

(leaf flycheck
    :doc "syntax check systen"
    :tag "develop" "elpa"
    :ensure t
    :defun flycheck-set-indication-mode
    :hook (prog-mode-hook . flycheck-mode)
    :custom ((flycheck-display-errors-delay . 0.3)
             (flycheck-indication-mode . 'left-margin)
             ) ;terminalで使うので、fringeではなくmarginに警告を表示
    :config (add-hook 'flycheck-mode-hook #'flycheck-set-indication-mode) ; flycheckのみでmarginを使用
    (leaf flycheck-inline
      :ensure t
      :hook (flycheck-mode-hook . flycheck-inline-mode)))

(leaf *python-develop
  :doc "my python develop environment"
  :tag "python" "develop" "elpa"
  :config
  (leaf py-isort
    :doc "automatic sort for import packages"
    :tag "python" "elpa" "sort"
    ;; :hook ((python-mode-hook .  '(lambda()
    ;;                                (add-hook 'before-save-hook 'py-isort-before-save))))
    :ensure t)

  ;; python 環境は elpy で設定するので不要
  ;; (leaf conda
  ;;   :doc "conda command for emacs"
  ;;   :tag "python" "env" "elpa"
  ;;   :ensure t
  ;;   :custom `((conda-anaconda-home . "~/miniconda3")))

  (leaf blacken
    :doc "Reformat python buffers using the black fomatter"
    :tag "python" "formatter" "elpa"
    :ensure t
    :custom ((blacken-line-length . 79) ; 1行の流さを79文字まで許可
             (blacken-skip-string-normalization . t))) ; 文字リテラルの「'」を「"」に変更しないように抑制

  (leaf elpy
    :doc "Emacs Python Development Environment"
    :tag "python" "develop" "elpa"
    :ensure t
    :init
    (elpy-enable)
    :config
    (remove-hook 'elpy-modules 'elpy-module-highlight-indentation) ;highlight-indent-guides を使う
    (remove-hook 'elpy-modules 'elpy-module-flymake) ;flycheck を使う
    (pyvenv-activate "~/miniconda3/envs/py39")
    :custom
    (elpy-rpc-python-command . "python3")
    (flycheck-python-flake8-executable . "flake8")
    (python-shell-completion-native-enable . t)
    :bind (elpy-mode-map
           ("C-c C-r f" . elpy-format-code))
    :hook ((elpy-mode-hook . flycheck-mode))))

;;; 事前に nodejs をインストールする
;;; https://ralacode.com/blog/post/install-nodejs-with-nvm/

;; (leaf lsp-mode
;;   :ensure t
;;   :commands (lsp lsp-deferred)
;;   :config
;;   :custom ((lsp-keymap-prefix . "C-c l")
;;            (lsp-log-io . t)
;;            (lsp-keep-workspace-alive . nil)
;;            (lsp-document-sync-method . 2)
;;            (lsp-response-timeout . 5)
;;            (lsp-enable-file-watchers . nil))
;;   :hook (lsp-mode-hook . lsp-headerline-breadcrumb-mode)
;;   :init (leaf lsp-ui
;;           :ensure t
;;           :after lsp-mode
;;           :custom ((lsp-ui-doc-enable . t)
;;                    (lsp-ui-doc-position . 'at-point)
;;                    (lsp-ui-doc-header . t)
;;                    (lsp-ui-doc-include-signature . t)
;;                    (lsp-ui-doc-max-width . 150)
;;                    (lsp-ui-doc-max-height . 30)
;;                    (lsp-ui-doc-use-childframe . nil)
;;                    (lsp-ui-doc-use-webkit . nil)
;;                    (lsp-ui-peek-enable . t)
;;                    (lsp-ui-peek-peek-height . 20)
;;                    (lsp-ui-peek-list-width . 50))
;;           :bind ((lsp-ui-mode-map ([remap xref-find-definitions] .
;;                                    lsp-ui-peek-find-definitions)
;;                                   ([remap xref-find-references] .
;;                                    lsp-ui-peek-find-references))
;;                  (lsp-mode-map ("C-c s" . lsp-ui-sideline-mode)
;;                                ("C-c d" . lsp-ui-doc-mode)))
;;           :hook ((lsp-mode-hook . lsp-ui-mode))))

;; (leaf lsp-pyright
;;   :ensure t
;;   :hook (python-mode-hook . (lambda ()
;;                               (require 'lsp-pyright)
;;                               (lsp-deferred))))

(leaf company
  :ensure t
  :leaf-defer nil
  :blackout company-mode
  :bind ((company-active-map
          ("M-n" . nil)
          ("M-p" . nil)
          ("C-s" . company-filter-candidates)
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)
          ("C-i" . company-complete-selection))
         (company-search-map
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)))
  :custom ((company-tooltip-limit         . 12)
           (company-idle-delay            . 0.5)
           (company-minimum-prefix-length . 1) ;; 1文字から補完開始
           (company-transformers          . '(company-sort-by-occurrence))
           (global-company-mode           . t)
           (company-selection-wrap-around . t)))

(leaf markdown-mode
  :doc "markdown mode configuration"
  :tag "markdown" "elpa"
  :ensure t
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)
         (("README\\.md\\'" . gfm-mode)))
  :custom ((markdown-fontify-code-blocks-natively . t))
  :defvar flycheck-checker
  :hook ((markdown-mode-hook . (lambda ()
                                 (setq tab-width 2)
                                 (setq flycheck-checker 'textlint)
                                 (flycheck-mode 1)))))

(leaf markdown-preview-mode
  :doc "preview markdown"
  :tag "markdown" "elpa"
  :ensure t
  :custom ((markdown-preview-stylesheets . '("https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/3.0.1/github-markdown.min.css"))))

(leaf sokoban
  :doc "sokoban additional configuration"
  :tag "game" "elpa"
  :ensure t
  :require t
  :defun sokoban-goto-level
  :custom `((sokoban-state-filename . ,(locate-user-emacs-file "games/sokoban-state")))
  :config
  (leaf *sokoban-my-defun
    :defvar sokoban-level-file sokoban-level
    :preface
    (defvar sokoban-max-level
      (with-temp-buffer
        (insert-file-contents sokoban-level-file)
        (goto-char (point-min))
        (when (re-search-forward "^;MAXLEVEL \\([0-9]+\\)$")
          (string-to-number (match-string 1)))))
    (defun sokoban-next-or-first-level ()
      "Go to next level. Next of max-level is level-1."
      (interactive)
      (sokoban-goto-level
       (if (= sokoban-level sokoban-max-level)
           1
         (1+ sokoban-level))))
    (defun sokoban-prev-or-last-level ()
      "Go to previous level. Previous of level-1 is max-level"
      (interactive)
      (sokoban-goto-level
       (if (= sokoban-level 1)
           sokoban-max-level
         (1- sokoban-level)))))
  :bind ((sokoban-mode-map (">" . sokoban-next-or-first-level)
                           ("<" . sokoban-prev-or-last-level)
                           ("h" . sokoban-move-left)
                           ("j" . sokoban-move-down)
                           ("k" . sokoban-move-up)
                           ("l" . sokoban-move-right)
                           ("/" . sokoban-undo))))

(leaf *output-org-agenda
  :config (org-agenda "nil" "a"))

(provide 'init)
;;; init.el ends here

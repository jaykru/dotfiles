(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("4b6cc3b60871e2f4f9a026a5c86df27905fb1b0e96277ff18a76a39ca53b82e1" "7ec8fd456c0c117c99e3a3b16aaf09ed3fb91879f6601b1ea0eeaee9c6def5d9" "551629d1e63bb66423dd80b3ec2d1a67611d1fa570e7238201e65b25a3b3834f" "1a6d120936f9df3f44953124dbf9e56b399e021702ca7d1844e6c5e1658b692b" "49cd634a5d2e294c281348ce933d2f17c19531998a262cbdbe763ef2fb41846b" "5e5771e6ea0c9500aa87e987ace1d9f401585e22a976777b6090a1554f3771c6" "9f297216c88ca3f47e5f10f8bd884ab24ac5bc9d884f0f23589b0a46a608fe14" "88f7ee5594021c60a4a6a1c275614103de8c1435d6d08cc58882f920e0cec65e" "f4d1b183465f2d29b7a2e9dbe87ccc20598e79738e5d29fc52ec8fb8c576fcfd" "4594d6b9753691142f02e67b8eb0fda7d12f6cc9f1299a49b819312d6addad1d" "7964b513f8a2bb14803e717e0ac0123f100fb92160dcf4a467f530868ebaae3e" "60ada0ff6b91687f1a04cc17ad04119e59a7542644c7c59fc135909499400ab8" "2e05569868dc11a52b08926b4c1a27da77580daa9321773d92822f7a639956ce" "1aa4243143f6c9f2a51ff173221f4fd23a1719f4194df6cef8878e75d349613d" "aec7b55f2a13307a55517fdf08438863d694550565dee23181d2ebd973ebd6b8" "ce4234c32262924c1d2f43e6b61312634938777071f1129c7cde3ebd4a3028da" "2078837f21ac3b0cc84167306fa1058e3199bbd12b6d5b56e3777a4125ff6851" "e77c88ec01da46eafc47464b72f5b8f3d8348a9fa252988373505b3ee617574a" "c1ced037e13e6c702c3dcb0a00b74f8f9ada5018ca45844adc8195a14087a067" "b4dc9265d66225f207112d7911457c24b12770b2c4fe1c9c32f9659c9cfdebc7" "0c08a5c3c2a72e3ca806a29302ef942335292a80c2934c1123e8c732bb2ddd77" "2dd4951e967990396142ec54d376cced3f135810b2b69920e77103e0bcedfba9" "631c52620e2953e744f2b56d102eae503017047fb43d65ce028e88ef5846ea3b" "7e377879cbd60c66b88e51fad480b3ab18d60847f31c435f15f5df18bdb18184" "02f57ef0a20b7f61adce51445b68b2a7e832648ce2e7efb19d217b6454c1b644" "636b135e4b7c86ac41375da39ade929e2bd6439de8901f53f88fde7dd5ac3561" "4ff1c4d05adad3de88da16bd2e857f8374f26f9063b2d77d38d14686e3868d8d" "51c71bb27bdab69b505d9bf71c99864051b37ac3de531d91fdad1598ad247138" "afa47084cb0beb684281f480aa84dab7c9170b084423c7f87ba755b15f6776ef" default))
 '(magit-todos-insert-after '(bottom) nil nil "Changed by setter of obsolete option `magit-todos-insert-at'")
 '(package-selected-packages '(dumb-jump))
 '(send-mail-function 'sendmail-send-it)
 '(warning-suppress-log-types
   '(((python python-shell-completion-native-turn-on-maybe))
     ((python python-shell-completion-native-turn-on-maybe))
     ((python python-shell-completion-native-turn-on-maybe))
     ((python python-shell-completion-native-turn-on-maybe))
     ((python python-shell-completion-native-turn-on-maybe))
     (emacs)
     (emacs)
     (defvaralias)))
 '(warning-suppress-types
   '(((python python-shell-completion-native-turn-on-maybe))
     ((python python-shell-completion-native-turn-on-maybe))
     ((python python-shell-completion-native-turn-on-maybe))
     ((python python-shell-completion-native-turn-on-maybe))
     (emacs)
     (emacs)
     (defvaralias))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; workaround a bug in macos sonoma
(tool-bar-mode)
(tool-bar-mode -1)
(setq python-shell-completion-native-enable nil)
(setq doom-unreal-buffer-functions '(minibufferp))

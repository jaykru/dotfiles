import XMonad
import XMonad.Util.EZConfig
import XMonad.Layout.BinarySpacePartition
import XMonad.Actions.Navigation2D

xmobarPath = "/usr/bin/xmobar"

main = do
  xmproc <- spawnPipe $ xmobarPath ++ " /home/j/.xmonad/xmobarrc"
  xmonad $ def { modMask = mod4Mask
               , Layout = emptyBSP }
    navigation2DP def
    ("k","h","j","l")
    [("M-", windowGo)
    ,("M-S-", windowSwap)] True
    
    `removeKeysP` ["M-S-<Return>"
                  ,"M-S-c"]
    `additionalKeysP` [ ("M-w", kill)
                      , ("M-<Space", spawn "rofi -show run")]
    

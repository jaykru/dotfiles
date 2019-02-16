import XMonad
import XMonad.Util.EZConfig
import XMonad.Layout.BinarySpacePartition
import XMonad.Actions.Navigation2DP

xmobarPath = "/path/to/xmobarbinary"

main = do
  xmproc <- spawnPipe $ xmobarPath ++ " /home/j/.xmobarrc"
  xmonad $ def { modMask = mod4Mask
               , myLayout = emptyBSP }
    navigation2DP def
    ("k","h","j","l")
    [("M-", windowGo)
    ,("M-S-", windowSwap)] True
    
    `removeKeysP` ["M-S-<Return>"
                  ,"M-S-c"]
    `additionalKeysP` [ ("M-w", kill)
                      , ("M-<Space", spawn "rofi -show run")]
    

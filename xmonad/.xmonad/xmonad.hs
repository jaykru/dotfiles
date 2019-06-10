import Data.List (sortBy)
import Data.Function (on)
import Control.Monad (forM_, join)
import XMonad.Util.Run (safeSpawn)
import XMonad.Util.NamedWindows (getName)
import qualified XMonad.StackSet as W
import XMonad
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.Maximize
import XMonad.Layout.Spacing
import XMonad.Actions.Navigation2D
import XMonad.Actions.PhysicalScreens

main = do 
  forM_ [".xmonad-workspace-log", ".xmonad-title-log"] $ \file -> do
  _ <- spawnPipe $ polybarPath ++ " example"
  _ <- safeSpawn "mkfifo" ["/tmp/" ++ file]
  xmonad $ docks $ navigation2DP def ("k","h","j","l") [("M-", windowGo)
                                                       ,("M-S-", windowSwap)] True
    def { modMask = mod4Mask
        , handleEventHook = handleEventHook def <+> fullscreenEventHook
        , manageHook = manageDocks <+> manageHook def
        , logHook = eventLogHook
        , layoutHook = avoidStruts $ (emptyBSP ||| Full)
        , focusedBorderColor = "#f44141"-- "#4e42f4"
        , normalBorderColor = "#000000"
        }
    `removeKeysP` ["M-p",
                   "M-S-q",
                   "M-S-<Return>"]
    `additionalKeysP` [ ("M-p", spawn "rofi -show run")
                      , ("M-<Return>", spawn "termite")
                      , ("M-f", withFocused (sendMessage . maximizeRestore))
                      , ("<XF86Tools>", spawn "i3lock -c 111111")
                      , ("<XF86AudioMute>", spawn "pactl set-sink-mute 0 toggle")
                      , ("<XF86AudioLowerVolume>", spawn "pactl set-sink-mute 0 false; pactl set-sink-volume 0 -10%")
                      , ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-mute 0 false; pactl set-sink-volume 0 +10%")
                      , ("<XF86MonBrightnessDown>", spawn "echo TODO")
                      , ("<XF86MonBrightnessUp>", spawn "echo TODO")
                      , ("<XF86Display>", spawn "autorandr")]
    
-- for polybar 
polybarPath = "/home/j/.nix-profile/bin/polybar"
eventLogHook = do
  winset <- gets windowset
  title <- maybe (return "") (fmap show . getName) . W.peek $ winset
  let currWs = W.currentTag winset
  let wss = map W.tag $ W.workspaces winset
  let wsStr = join $ map (fmt currWs) $ sort' wss

  io $ appendFile "/tmp/.xmonad-title-log" (title ++ "\n")
  io $ appendFile "/tmp/.xmonad-workspace-log" (wsStr ++ "\n")

  where fmt currWs ws
          | currWs == ws = "[" ++ ws ++ "]"
          | otherwise    = " " ++ ws ++ " "
        sort' = sortBy (compare `on` (!! 0))

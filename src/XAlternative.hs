{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module XAlternative where


import           Control.Monad (liftM2)

import           Data.Bits ((.|.))
import           Data.Map.Strict (Map)
import qualified Data.Map.Strict as M
import           Data.Semigroup ((<>))
import qualified Data.Text as T

import           Graphics.X11.ExtraTypes.XF86
import           Graphics.X11.Types

import qualified System.Taffybar.Hooks.PagerHints as TP

import           XAlternative.Config (Config)
import qualified XAlternative.Config as C

import           XMonad (X, XConfig (..), Layout, KeyMask, KeySym)
import qualified XMonad as X
import           XMonad.Layout (Choose, Tall, Mirror, Full)

import           XMonad.Actions.DwmPromote (dwmpromote)
import           XMonad.Hooks.EwmhDesktops (ewmh)
import           XMonad.Hooks.ManageDocks (AvoidStruts, ToggleStruts (..))
import qualified XMonad.Hooks.ManageDocks as Docks
import           XMonad.Layout.LayoutModifier (ModifiedLayout)
import           XMonad.Prompt.RunOrRaise (runOrRaisePrompt)
import           XMonad.Prompt.XMonad (xmonadPrompt)
import           XMonad.Util.CustomKeys (customKeys)


xAlternative :: Config -> IO ()
xAlternative cfg = do
  X.launch $ taffybar (xConfig cfg)

type Layouts = Choose Tall (Choose (Mirror Tall) Full)

xConfig :: Config -> XConfig Layouts
xConfig (C.Config (C.General term bWidth)) =
  X.def {
      terminal = T.unpack term
    , modMask = mod4Mask
    , borderWidth = fromIntegral bWidth
    , keys = xKeys
    }

xKeys :: XConfig Layout -> Map (KeyMask, KeySym) (X ())
xKeys =
  customKeys (const []) $ \(XConfig {modMask = mm}) -> [
      ((mm, xF86XK_MonBrightnessDown), X.spawn "backlight down")
    , ((mm, xF86XK_MonBrightnessUp), X.spawn "backlight up")
    , ((mm .|. shiftMask, xK_r), X.restart "xalt" True)
    , ((mm, xK_Return), dwmpromote)
    , ((mm, xK_r), runOrRaisePrompt X.def)
    , ((mm, xK_x), xmonadPrompt X.def)
    ]

-- -----------------------------------------------------------------------------
-- Taffybar

taffybar ::
     XConfig Layouts
  -> XConfig (ModifiedLayout AvoidStruts Layouts)
taffybar cfg = do
  ewmh . TP.pagerHints $ Docks.docks cfg {
      layoutHook = Docks.avoidStruts (layoutHook cfg)
    , keys = liftM2 (<>) setStrutsKey (keys cfg)
    }

setStrutsKey :: XConfig a -> Map (KeyMask, KeySym) (X ())
setStrutsKey =
  (`M.singleton` X.sendMessage ToggleStruts) . toggleStrutsKey

toggleStrutsKey :: XConfig t -> (KeyMask, KeySym)
toggleStrutsKey XConfig{modMask = modm} = (modm, xK_b )

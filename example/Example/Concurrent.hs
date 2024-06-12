module Example.Concurrent where

import Data.Text (pack)
import Effectful
import Example.Effects.Debug
import Web.Hyperbole


page :: (Hyperbole :> es, Debug :> es, IOE :> es) => Page es Response
page = do
  handle content

  load $ do
    pure $ do
      col (pad 20) $ do
        hyper (Contents 100) $ viewPoll 1
        hyper (Contents 2000) $ viewPoll 100


data Contents = Contents Milliseconds
  deriving (Generic, Param)
instance HyperView Contents where
  type Action Contents = ContentsAction


data ContentsAction
  = Load Int
  deriving (Generic, Param)


content :: (Hyperbole :> es, Debug :> es, IOE :> es) => Contents -> ContentsAction -> Eff es (View Contents ())
content (Contents dl) (Load n) = do
  -- BUG: this is blocking the thread, so the short poll has to wait for the long to finish before continuing
  delay dl
  pure $ viewPoll (n + 1)


viewPoll :: Int -> View Contents ()
viewPoll n = do
  onLoad (Load n) 0 $ do
    row (gap 10) $ do
      el_ "Polling:"
      text $ pack (show n)
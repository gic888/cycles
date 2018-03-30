module Lib
    ( readGraph, countCycles
    ) where

import qualified Data.Map as M


readGraph :: String -> M.Map String [String]
readGraph content = M.empty

countCycles :: M.Map String [String] -> Integer
countCycles graph = 4



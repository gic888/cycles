module Lib
    ( readGraph, countCycles
    ) where

import qualified Data.Map as M
import qualified Data.List.Split as S


readGraph :: String -> M.Map String [String]
readGraph content = M.fromList [(head lw, tail lw) |
  l <- lines content,
  let lw =  S.splitOn " " l ,
  length l > 0,
  head l /= '#']

countCycles :: M.Map String [String] -> Int
countCycles graph = length (M.keys graph)



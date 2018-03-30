module Lib
    ( readGraph, countCycles
    ) where

import qualified Data.Map as M
import qualified Data.List.Split as S

type Vid = String
type Graph = M.Map Vid [Vid]
type Path = (Vid, [Vid], Graph)

endOf:: Path -> Vid
endOf (s, [], _) = s
endOf (_, h : t, _) = h

nextFrom :: Path -> [Vid]
nextFrom p@ (_, _, g) = case M.lookup (endOf p) g of
  Just l -> l
  Nothing -> []


readGraph :: String -> Graph
readGraph content = M.fromList [(head lw, tail lw) |
  l <- lines content,
  let lw =  S.splitOn " " l ,
  length l > 0,
  head l /= '#']

countCycles :: Graph -> Int
countCycles graph = sum [countCyclesFrom (x, [], graph) | x <- M.keys graph]

countCyclesFrom :: Path -> Int
countCyclesFrom p = sum [countCyclesAt x p | x <- nextFrom p]

countCyclesAt :: Vid -> Path -> Int
countCyclesAt v p@(s, m, g)
  | v == s = 1
  | v > s && not (elem v m) = countCyclesFrom (s, v : m, g)
  | otherwise = 0




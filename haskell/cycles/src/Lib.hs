module Lib
    ( readGraph, countCycles
    ) where

import qualified Data.Map as M
import qualified Data.List.Split as Spl
import qualified Data.Set as S
import Control.Parallel (par)
import Control.Parallel.Strategies (using, rdeepseq)

type Vid = String
type Graph = M.Map Vid [Vid]
type Path = (Vid, Vid, S.Set Vid, Graph)

nextFrom :: Path -> [Vid]
nextFrom p@ (_, e, _, g) = case M.lookup e g of
  Just l -> l
  Nothing -> []

pCount :: (Vid -> Int) -> [Vid] -> Int
pCount f [] = 0
pCount f (x : xs) = let r = (f x) `using` rdeepseq in
  r `par` r + pCount f xs

readGraph :: String -> Graph
readGraph content = M.fromList [(head lw, tail lw) |
  l <- lines content,
  let lw =  Spl.splitOn " " l ,
  length l > 0,
  head l /= '#']

sCount :: Graph -> Int
sCount graph = sum [countCyclesFrom (x, x, S.empty, graph) | x <- M.keys graph]

countCycles :: Graph -> Int
countCycles graph = pCount (\x -> countCyclesFrom (x, x, S.empty, graph))  (M.keys graph)

countCyclesFrom :: Path -> Int
countCyclesFrom p = sum [countCyclesAt x p | x <- nextFrom p]

countCyclesAt :: Vid -> Path -> Int
countCyclesAt v p@(s, e, m, g)
  | v == s = 1
  | v > s && not (S.member v m) = countCyclesFrom (s, v, S.insert v m, g)
  | otherwise = 0




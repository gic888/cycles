module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.MonadZero (guard)
import Data.Array as A
import Data.Maybe (Maybe(..))
import Data.StrMap as M
import Control.Monad.Eff.Now as Now
import Data.String (Pattern(..), split, charAt)
import Data.Tuple (Tuple(..))




main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  let start = Now.now
  let n = countCycles (readGraph (getData 35))
  let stop = Now.now
  log (show n)

type Vid = String
type Vids = Array Vid
type Graph = M.StrMap Vids
type Path = { from :: Vid, to :: Vid, via :: M.StrMap Int, graph :: Graph}

nextFrom :: Path -> Vids
nextFrom p = case M.lookup p.to p.graph of
  Just l -> l
  Nothing -> []

usableLine :: String -> Boolean
usableLine s = case charAt 0 s of 
  Nothing -> false 
  Just '#' -> false
  otherwise -> true

tupleate :: Array String -> Tuple String (Array String)
tupleate a = case A.uncons a of 
  Nothing -> Tuple "" []
  Just r -> Tuple r.head r.tail

mapLines :: String -> Array (Tuple String (Array String))
mapLines s = do 
  line <- split (Pattern "\n") s
  guard $ usableLine line
  let words = split (Pattern " ") line
  pure (tupleate words)

readGraph :: String -> Graph
readGraph content = M.fromFoldable (mapLines  content)

countCycles :: Graph -> Int
countCycles graph = reduce_sum (\k -> countCyclesFrom { from: k, to: k, via: M.empty, graph: graph}) (M.keys graph)

sum :: Array Int -> Int
sum a = A.foldl ( + ) 0 a

reduce_sum :: forall t. ( t -> Int ) -> Array t -> Int
reduce_sum f a = sum (map f a)

countCyclesFrom :: Path -> Int
countCyclesFrom p = reduce_sum (\k -> countCyclesAt k p) (nextFrom p)

pathWith :: String -> Path -> Path
pathWith k p = p { to = k, via = M.insert k 1 p.via }

countCyclesAt :: Vid -> Path -> Int
countCyclesAt v p = 
  if v == p.from then 1 
  else if v > p.from && not (M.member v p.via) then countCyclesFrom (pathWith v p)
  else 0

getData :: Int -> String
getData n = 
  if n == 20 then  """
0 4 10 19
1 0 6 9
2
3 4 11 19
4 1
5 1 4 12
6 14
7 3 8 13 19
8 1
9
10 14 18
11 12
12 5 16
13
14 16
15 10 11
16 0 17
17 3
18 3 8 12
19 1 2 5 8 9 17 18
""" else """
0 33
1 2 18 25
2 3 4 17 27
3 12 20 25
4 28 30
5 1 11 31
6 9 17 26 30 34
7 5 19
8 2 4 9 17
9 5 14 15 24 27 33 34
10 12 14 18 30 34
11 1 2 13 16 32
12 3 26 27 28 32
13 8 25 28
14 22
15 8 14 24 31
16 17 18 29
17 9 16 22 33 34
18 3 9 14 16 22 26
19 3 7 16
20 5 14 16 33
21 11
22
23 0 5 31
24 26 34
25 7 20
26 6 10 13 15 28
27 15 16 21
28 11 27 33
29 2 3
30 6 18 23
31 10 11 12 33
32 3 4 5 14 30
33 32
34 13 17 22
"""




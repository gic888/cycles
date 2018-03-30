module Main where

import Lib
import System.Environment

main :: IO ()
main = do
  args <- getArgs
  let n = if (length args) > 0 then args !! 0 else "20"
  content <- readFile ("../../data/graph" ++ n ++ ".adj")

  putStrLn "wat"


module Eval (evalBFAst, initBFState) where

import Data.Array.IO (IOArray)
import Data.Array.MArray (newArray, readArray, writeArray)
import Data.Char (chr)

import Types (BFAst, BFAstE(..), BFState(..))

initBFState :: IO BFState
initBFState = do
  mem <- newArray (0, 1024) 0
  return BFState {dataP = 0, mem}

modifyArray :: IOArray Int Int -> Int -> (Int -> Int) -> IO ()
modifyArray arr ix f = readArray arr ix >>= writeArray arr ix . f

evalBFAst :: BFState -> BFAst -> IO BFState
evalBFAst st [] = pure st
evalBFAst st@(BFState {dataP, mem}) ast@(x : xs) = case x of
  Inc -> do
    modifyArray mem dataP (+ 1)
    evalBFAst st xs
  Dec -> do
    modifyArray mem dataP (subtract 1)
    evalBFAst st xs
  Movr -> evalBFAst st {dataP = dataP + 1} xs
  Movl -> evalBFAst st {dataP = dataP - 1} xs
  Loop ys -> do
    currentValue <- readArray mem dataP
    if currentValue == 0
      then evalBFAst st xs -- jump over the looped part
      else evalBFAst st ys >>= (`evalBFAst` ast) -- loop
  Read -> do
    putStrLn "Enter value: "
    int <- getLine
    writeArray mem dataP (read int)
    evalBFAst st xs
  Show -> do
    readArray mem dataP >>= (putStr . (: []) . chr)
    evalBFAst st xs

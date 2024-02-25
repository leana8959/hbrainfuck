module Eval (evalBFAst, initBFState) where

import Control.Monad.State (MonadIO(liftIO), MonadState(get, put), StateT)

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

type BFOutput = [Char]

evalBFAst :: BFAst -> StateT BFState IO BFOutput
evalBFAst [] = return []
evalBFAst ast@(x : xs) = do
  st@(BFState {dataP, mem}) <- get
  case x of
    Inc n -> do
      liftIO $ modifyArray mem dataP (+ n)
      evalBFAst xs
    Dec n -> do
      liftIO $ modifyArray mem dataP (subtract n)
      evalBFAst xs
    Movr n -> do
      put st {dataP = dataP + n}
      evalBFAst xs
    Movl n -> do
      put st {dataP = dataP - n}
      evalBFAst xs
    Loop ys -> do
      currentValue <- liftIO $ readArray mem dataP
      if currentValue == 0
        then evalBFAst xs -- jump over the looped part
        else (++) <$> evalBFAst ys <*> evalBFAst ast -- loop
    Read -> do
      liftIO $ putStrLn "Enter value: "
      int <- liftIO getLine
      liftIO $ writeArray mem dataP (read int)
      evalBFAst xs
    Show -> do
      value <- liftIO $ readArray mem dataP
      (chr value :) <$> evalBFAst xs

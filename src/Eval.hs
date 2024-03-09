module Eval (evalBFAst, initBFState) where

import Control.Monad.State (MonadIO(liftIO), MonadState(get, put), StateT)

import Data.Array.IO (IOArray)
import Data.Array.MArray (newArray, readArray, writeArray)
import Data.Char (chr, ord)

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
    Inc -> do
      liftIO $ modifyArray mem dataP (+ 1)
      evalBFAst xs
    Dec -> do
      liftIO $ modifyArray mem dataP (subtract 1)
      evalBFAst xs
    Movr -> do
      put st {dataP = dataP + 1}
      evalBFAst xs
    Movl -> do
      put st {dataP = dataP - 1}
      evalBFAst xs
    Loop ys -> do
      currentValue <- liftIO $ readArray mem dataP
      if currentValue == 0
        then evalBFAst xs -- jump over the looped part
        else (++) <$> evalBFAst ys <*> evalBFAst ast -- loop
    Read -> do
      liftIO $ putStrLn "Enter a byte (as ascii char): "
      input <- liftIO getChar
      liftIO $ writeArray mem dataP (ord input)
      evalBFAst xs
    Show -> do
      value <- liftIO $ readArray mem dataP
      (chr value :) <$> evalBFAst xs

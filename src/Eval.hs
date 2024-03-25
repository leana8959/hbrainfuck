module Eval (evalBFAst) where

import Prelude hiding (read)

import Control.Monad.State (MonadIO(liftIO), MonadState(get, put), StateT)
import Data.Char (chr, ord)

import Types (BFAst, BFAstE(..), BFState, backward, forward, modify, headOfTape)

type BFOutput = [Char]

evalBFAst :: BFAst -> StateT BFState IO BFOutput
evalBFAst [] = return []
evalBFAst ast@(x : xs) = do
  tape <- get
  case x of
    Inc -> do
      put $ modify (+ 1) tape
      evalBFAst xs
    Dec -> do
      put $ modify (subtract 1) tape
      evalBFAst xs
    Movr -> do
      put $ forward tape
      evalBFAst xs
    Movl -> do
      put $ backward tape
      evalBFAst xs
    Loop ys -> do
      let value = headOfTape tape
      if value == 0
        then evalBFAst xs -- jump over the looped part
        else (++) <$> evalBFAst ys <*> evalBFAst ast -- loop
    Read -> do
      liftIO $ putStrLn "Enter a byte (as ascii char): "
      input <- liftIO getChar
      put $ modify (const . fromIntegral . ord $ input) tape
      evalBFAst xs
    Show -> do
      let value = headOfTape tape
      (chr (fromIntegral value) :) <$> evalBFAst xs

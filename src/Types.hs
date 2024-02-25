module Types (BFAst, BFAstE (..), BFState (..)) where

import Data.Array.IO (IOArray)

type BFAst = [BFAstE]

data BFAstE
  = Inc Int
  | Dec Int
  | Movr Int
  | Movl Int
  | Loop BFAst
  | Read
  | Show
  deriving (Show, Eq)

data BFState = BFState
  { dataP :: Int
  -- ^ data pointer
  , mem   :: IOArray Int Int
  -- ^ one dimentional array that's initialized at 0
  }

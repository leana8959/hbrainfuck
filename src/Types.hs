module Types (BFAst, BFAstE (..), BFState, Tape, forward, backward, modify, headOfTape, emptyUnboundTape) where

import Data.Word (Word8)
import Prelude hiding (read)

type BFAst = [BFAstE]

data BFAstE
  = Inc
  | Dec
  | Movr
  | Movl
  | Loop BFAst
  | Read
  | Show
  deriving (Show, Eq)

type BFState = Tape Word8

-- A zipper implementation of the "unbounded" tape of the evaluator
data Tape a = Tape ([a], [a])

emptyUnboundTape :: Tape Word8
emptyUnboundTape = Tape (repeat 0, repeat 0)

forward :: Tape a -> Tape a
forward (Tape (xs, y: ys)) = Tape (y : xs, ys)

backward :: Tape a -> Tape a
backward (Tape (x: xs, ys)) = Tape (xs, x : ys)

modify :: (a -> a) -> Tape a -> Tape a
modify f (Tape (xs, y : ys)) = Tape (xs, f y : ys)

headOfTape :: Tape a -> a
headOfTape (Tape (_, y : _)) = y

module Main where

import Control.Monad.State (evalStateT)
import Data.Bifunctor (Bifunctor(bimap))
import qualified Data.Text.IO as TIO
import Eval (evalBFAst, initBFState)
import GHC.IO.IOMode (IOMode(ReadMode))
import System.Environment (getArgs)
import System.IO (openFile)
import Text.Megaparsec (errorBundlePretty, runParser)

import Parser (bfParser)

main :: IO ()
main = do
  (fname : _) <- getArgs
  content <- openFile fname ReadMode >>= TIO.hGetContents

  state <- initBFState
  let output = bimap errorBundlePretty (($ state) . evalStateT . evalBFAst)
             . runParser bfParser "file"
             $ content

  case output of
    Right resultState -> do
        result <- resultState
        putStrLn result
        putStrLn "The program has ended"
    Left err          -> putStrLn $ "failed because " <> err

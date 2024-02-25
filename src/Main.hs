module Main where

import Control.Monad.State (evalStateT)
import Data.Bifunctor (Bifunctor(bimap))
import qualified Data.Text.IO as TIO
import Eval (evalBFAst, initBFState)
import GHC.IO.IOMode (IOMode(ReadMode))
import System.Environment (getArgs)
import System.IO (openFile)
import Text.Megaparsec (errorBundlePretty, runParser)

import Parser (bfParserToEof)

main :: IO ()
main = do
  args <- getArgs

  content <- case args of
    (fname : _) | fname /= "-" ->
      openFile fname ReadMode >>= TIO.hGetContents
    _ -> TIO.getContents

  state <- initBFState
  let output = bimap errorBundlePretty (($ state) . evalStateT . evalBFAst)
             . runParser bfParserToEof "file"
             $ content

  case output of
    Right resultState -> do
        result <- resultState
        putStrLn result
        putStrLn "The program has ended"
    Left err          -> putStrLn $ "failed because " <> err

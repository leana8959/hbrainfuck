module Main where

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
  (fname : _) <- getArgs
  content <- openFile fname ReadMode >>= TIO.hGetContents

  state <- initBFState
  let output =
        bimap errorBundlePretty (evalBFAst state)
          . runParser bfParserToEof "file"
          $ content

  case output of
    Right resultState -> resultState >> putStrLn "The program has ended"
    Left err          -> putStrLn $ "failed because " <> err

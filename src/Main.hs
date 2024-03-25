module Main where

import Data.Bifunctor (Bifunctor(bimap))
import qualified Data.Text.IO as TIO
import GHC.IO.IOMode (IOMode(ReadMode))
import Options.Applicative
  (ParserInfo, argument, execParser, fullDesc, header, help, helper, info,
  metavar, progDesc, str, (<**>))
import System.IO (openFile)
import Control.Monad.State (evalStateT)
import Text.Megaparsec (errorBundlePretty, runParser)

import Parser (bfParserToEof)
import Eval (evalBFAst)
import Types (emptyUnboundTape)

argsParser :: ParserInfo String
argsParser = withInfo (pFname <**> helper)
  where
    withInfo = flip info
      ( fullDesc
        <> header "hbrainfuck - a simple interpreter for brainfuck"
        <> progDesc "Interpretes a program written in the brainfuck language and show the result"
      )
    pFname = argument str (metavar "PROGRAM" <> help "Path to the program to be interpreted")

main :: IO ()
main = do
  file <- execParser argsParser

  content <- case file of
    fname -> openFile fname ReadMode >>= TIO.hGetContents

  let output = bimap errorBundlePretty (($ emptyUnboundTape) . evalStateT . evalBFAst)
             . runParser bfParserToEof "file"
             $ content

  case output of
    Right resultState -> putStrLn =<< resultState
    Left err -> putStrLn $ "failed because " <> err

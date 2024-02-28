module Main where

import Control.Monad.State (evalStateT)
import Data.Bifunctor (Bifunctor(bimap))
import qualified Data.Text.IO as TIO
import Eval (evalBFAst, initBFState)
import GHC.IO.IOMode (IOMode(ReadMode))
import Options.Applicative
  (ParserInfo, argument, execParser, fullDesc, header, help, helper, info,
  metavar, optional, progDesc, str, (<**>))
import System.IO (openFile)
import Text.Megaparsec (errorBundlePretty, runParser)

import Parser (bfParserToEof)

argsParser :: ParserInfo (Maybe String)
argsParser = withInfo (p <**> helper)
  where
    withInfo = flip info
      ( fullDesc
        <> header "hbrainfuck - a simple interpreter for brainfuck"
        <> progDesc "Interpretes a program written in the brainfuck language and show the result"
      )
    p = optional
        (argument str (metavar "FILEPATH" <> help "Which file to read from"))

main :: IO ()
main = do
  file <- execParser argsParser

  content <- case file of
    Just fname -> openFile fname ReadMode >>= TIO.hGetContents
    Nothing    -> TIO.getContents

  state <- initBFState
  let output = bimap errorBundlePretty (($ state) . evalStateT . evalBFAst)
             . runParser bfParserToEof "file"
             $ content

  case output of
    Right resultState -> putStrLn =<< resultState
    Left err -> putStrLn $ "failed because " <> err

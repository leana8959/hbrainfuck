module Main where

import Test.Hspec

import Eval (evalBFAst, initBFState)
import Parser (bfParserToEof)
import Types

import Control.Monad.State

import Test.Hspec.Megaparsec (shouldParse)
import Text.Megaparsec (runParser)

additionExample :: BFAst
additionExample = [ Inc, Inc
                  , Movr, Inc, Inc, Inc, Inc, Inc
                  , Loop [Movl, Inc, Movr, Dec]
                  , Inc, Inc, Inc, Inc, Inc, Inc, Inc, Inc
                  , Loop [Movl, Inc, Inc, Inc, Inc, Inc, Inc, Movr, Dec]
                  , Movl, Show
                  ]

spec :: Spec
spec = do
  describe "Parser" do
    it "should parse addition example" do
      runParser bfParserToEof "" "++ > +++++ [ < + > - ] ++++ ++++ [ < +++ +++ > - ] < ." `shouldParse` additionExample
  describe "Eval" do
    it "should evaluate addition example" do
      initState <- initBFState
      bfOutput <- evalStateT (evalBFAst additionExample) initState
      bfOutput `shouldBe` "7"

main :: IO ()
main = hspec spec

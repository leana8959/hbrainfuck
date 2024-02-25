module Main where

import Test.Hspec

import Eval (evalBFAst, initBFState)
import Parser (bfParser)
import Types

import Control.Monad.State

import Test.Hspec.Megaparsec (shouldParse)
import Text.Megaparsec (runParser)

additionExample :: BFAst
additionExample = [ Inc 2
                  , Movr 1, Inc 5
                  , Loop [Movl 1, Inc 1, Movr 1, Dec 1]
                  , Inc 7
                  , Loop [Movl 1, Inc 6, Movr 1, Dec 1]
                  , Movl 1, Show
                  ]

spec :: Spec
spec = do
  describe "Parser" do
    it "should parse addition example" do
      runParser bfParser "" "++ > +++++ [ < + > - ] ++++ ++++ [ < +++ +++ > - ] < ." `shouldParse` additionExample
  describe "Eval" do
    it "should evaluate addition example" do
      initState <- initBFState
      bfOutput <- evalStateT (evalBFAst additionExample) initState
      bfOutput `shouldBe` "7"

main :: IO ()
main = hspec spec

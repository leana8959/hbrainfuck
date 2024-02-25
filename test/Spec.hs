module Main where

import Test.Hspec

import Parser (bfParserToEof)
import Types

import Test.Hspec.Megaparsec (shouldParse)
import Text.Megaparsec (runParser)

spec :: Spec
spec = do
  describe "Parser" $ do
    it "should parse addition example"
      $ runParser bfParserToEof "" "++ > +++++ [ < + > - ] ++++ ++++ [ < +++ +++ > - ] < ."
      `shouldParse` [ Inc
                    , Inc
                    , Movr
                    , Inc
                    , Inc
                    , Inc
                    , Inc
                    , Inc
                    , Loop [Movl, Inc, Movr, Dec]
                    , Inc
                    , Inc
                    , Inc
                    , Inc
                    , Inc
                    , Inc
                    , Inc
                    , Inc
                    , Loop [Movl, Inc, Inc, Inc, Inc, Inc, Inc, Movr, Dec]
                    , Movl
                    , Show
                    ]

-- it "should eval addition example"
--   $

main :: IO ()
main = hspec spec

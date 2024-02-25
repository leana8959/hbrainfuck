module Parser (bfParserToEof) where

import Data.Text (Text)
import Data.Void (Void)
import Text.Megaparsec
  (MonadParsec(eof), Parsec, between, choice, many, noneOf, skipMany)
import Text.Megaparsec.Char (char)

import Types (BFAst, BFAstE(..))

type Input = Text
type BFParser = Parsec Void Input

sc :: BFParser ()
sc = skipMany (noneOf allowedChars)
  where allowedChars = ['>', '<', '+', '-', ',', '.', '[', ']']

bfParser :: BFParser BFAst
bfParser = many (parseOne <* sc)
  where parseOne = choice
          [ Movr <$ char '>'
          , Movl <$ char '<'
          , Inc <$ char '+'
          , Dec <$ char '-'
          , Read <$ char ','
          , Show <$ char '.'
          , Loop <$> between (char '[' <* sc) (char ']') bfParser
          ]

bfParserToEof :: BFParser BFAst
bfParserToEof = bfParser <* eof

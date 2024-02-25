module Parser (bfParser) where

import Data.Text (Text)
import Data.Void (Void)
import Text.Megaparsec
  (MonadParsec(eof), Parsec, between, choice, many, noneOf, skipMany, some)
import Text.Megaparsec.Char (char)

import Types (BFAst, BFAstE(..))

type Input = Text
type BFParser = Parsec Void Input

sc :: BFParser ()
sc = skipMany (noneOf allowedChars)
  where allowedChars = ['>', '<', '+', '-', ',', '.', '[', ']']

token :: Char -> BFParser Char
token c = char c <* sc

bfParserRec :: BFParser BFAst
bfParserRec = many parseOne
  where parseOne = choice
          [ Movr . length <$> some (token '>')
          , Movl . length <$> some (token '<')
          , Inc . length <$> some (token '+')
          , Dec . length <$> some (token '-')
          , Read <$ token ','
          , Show <$ token '.'
          , Loop <$> between (token '[') (token ']') bfParserRec
          ]

bfParser :: BFParser BFAst
bfParser = bfParserRec <* eof

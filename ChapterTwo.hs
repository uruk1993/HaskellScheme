module Main where
import           System.Environment
import           Text.ParserCombinators.Parsec hiding (spaces)
import           Control.Monad

symbol::Parser Char
symbol =oneOf "!$%&|*+-/:<=?>@^_~#"

data LispVal
  = Atom String
  | List [LispVal]
  | DottedList [LispVal]
               LispVal
  | Number Integer
  | String String
  | Bool Bool

readExpr::String -> String
readExpr input =
  case parse parseExpr "lisp" input of
    Left err  -> "No match: " ++ show err
    Right val -> "Found value"

spaces::Parser()
spaces = skipMany1 space


parseString :: Parser LispVal
parseString = do
  char '"'
  x <- many (noneOf "\"")
  char '"'
  return $ String x

parseAtom::Parser LispVal
parseAtom = do
  first <- letter <|> symbol
  rest <- many (letter <|> digit <|> symbol)
  let atom = first : rest
  return $
    case atom of
      "#t" -> Bool True
      "#f" -> Bool False
      otherwise -> Atom atom

parseNumber :: Parser LispVal
parseNumber = fmap (Number . read) $ many1 digit

parseExpr :: Parser LispVal
parseExpr = parseAtom <|> parseNumber <|> parseString

parseList :: Parser LispVal
parseList=liftM List $ sepBy parseExpr spaces


main::IO()
main = do
  args <- getArgs
  putStrLn . readExpr . head $args

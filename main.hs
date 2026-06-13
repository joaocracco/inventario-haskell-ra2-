-- Sistema de Inventario em Haskell - Trabalho RA2
-- A ideia aqui e separar bem a logica pura das operacoes de I/O.
-- O estado fica salvo em disco e cada operacao vai pro log de auditoria.

module Main where

import qualified Data.Map as Map
import Data.Map (Map)
import Data.Time (UTCTime, getCurrentTime)
import Data.List (sortBy, isInfixOf)
import Data.Ord (comparing)
import Control.Exception (catch, IOException)
import System.IO (hSetBuffering, stdout, BufferMode(NoBuffering))
import Text.Read (readMaybe)


-- Tipos de dados  (Mathias)

-- Cada produto do estoque
data Item = Item
  { itemID     :: String
  , nome       :: String
  , quantidade :: Int
  , categoria  :: String
  } deriving (Show, Read, Eq)

-- O inventario em si: um mapa do id pro item
type Inventario = Map String Item

-- Os tipos de acao que registramos no log
data AcaoLog = Add | Remove | Update | QueryFail
  deriving (Show, Read, Eq)

-- Resultado de uma operacao: deu certo ou falhou (com a mensagem)
data StatusLog = Sucesso | Falha String
  deriving (Show, Read, Eq)

-- Uma linha do log de auditoria
data LogEntry = LogEntry
  { timestamp :: UTCTime
  , acao      :: AcaoLog
  , detalhes  :: String
  , status    :: StatusLog
  } deriving (Show, Read, Eq)

-- Quando uma operacao da certo, ela devolve o novo inventario + a linha de log
type ResultadoOperacao = (Inventario, LogEntry)


-- Logica de negocio - funcoes puras  (Leonardo)

-- Adiciona um item novo. Nao deixa repetir id nem quantidade negativa.
addItem :: UTCTime -> String -> String -> Int -> String
        -> Inventario -> Either String ResultadoOperacao
addItem t iid n qtd cat inv
  | qtd < 0 = Left "Quantidade nao pode ser negativa."
  | Map.member iid inv =
      Left ("Item com ID '" ++ iid ++ "' ja existe.")
  | otherwise =
      let novoItem = Item iid n qtd cat
          novoInv  = Map.insert iid novoItem inv
          entry    = LogEntry t Add
                       ("id=" ++ iid ++ " Adicionado: " ++ n ++ ", qtd=" ++ show qtd)
                       Sucesso
      in Right (novoInv, entry)

-- Tira uma quantidade do estoque. Reclama se nao existe ou se nao tem o suficiente.
removeItem :: UTCTime -> String -> Int
           -> Inventario -> Either String ResultadoOperacao
removeItem t iid qtd inv =
  case Map.lookup iid inv of
    Nothing -> Left ("Item '" ++ iid ++ "' nao encontrado.")
    Just item
      | qtd <= 0 ->
          Left "Quantidade a remover deve ser positiva."
      | quantidade item < qtd ->
          Left ("Estoque insuficiente para '" ++ iid ++ "'. Disponivel: "
                ++ show (quantidade item) ++ ", solicitado: " ++ show qtd)
      | otherwise ->
          let itemAtualizado = item { quantidade = quantidade item - qtd }
              novoInv = Map.insert iid itemAtualizado inv
              entry   = LogEntry t Remove
                          ("id=" ++ iid ++ " Removido: " ++ show qtd
                           ++ ", restante=" ++ show (quantidade itemAtualizado))
                          Sucesso
          in Right (novoInv, entry)

-- Muda a quantidade de um item pra um valor exato. So funciona se o item existir.
updateQty :: UTCTime -> String -> Int
          -> Inventario -> Either String ResultadoOperacao
updateQty t iid novaQtd inv =
  case Map.lookup iid inv of
    Nothing -> Left ("Item '" ++ iid ++ "' nao encontrado.")
    Just item
      | novaQtd < 0 ->
          Left "Quantidade nao pode ser negativa."
      | otherwise ->
          let itemAtualizado = item { quantidade = novaQtd }
              novoInv = Map.insert iid itemAtualizado inv
              entry   = LogEntry t Update
                          ("id=" ++ iid ++ " Atualizado: qtd=" ++ show novaQtd)
                          Sucesso
          in Right (novoInv, entry)

-- Helper pra montar uma linha de log quando a operacao falha
logEntryFalha :: UTCTime -> AcaoLog -> String -> String -> LogEntry
logEntryFalha t ac det msg = LogEntry t ac det (Falha msg)


-- Relatorios sobre o log - funcoes puras  (Matheus)

-- Pega tudo que aconteceu com um item especifico
historicoPorItem :: String -> [LogEntry] -> [LogEntry]
historicoPorItem iid = filter (\e -> iid `isInfixOf` detalhes e)

-- So as linhas que deram erro
logsDeErro :: [LogEntry] -> [LogEntry]
logsDeErro = filter isFalha
  where isFalha e = case status e of
                      Falha _ -> True
                      Sucesso -> False

-- Qual item mais apareceu nas operacoes (id e quantas vezes)
itemMaisMovimentado :: [LogEntry] -> Maybe (String, Int)
itemMaisMovimentado entries =
  let nomes = concatMap extrai entries
      contagem = Map.toList (Map.fromListWith (+) [(x, 1) | x <- nomes])
  in if null contagem
       then Nothing
       else Just (head (sortBy (flip (comparing snd)) contagem))
  where
    -- a gente guarda o id no detalhe como "id=algumacoisa", entao e so pegar isso
    extrai e = case filter (\w -> take 3 w == "id=") (words (detalhes e)) of
      (w:_) -> [drop 3 w]
      []    -> []

-- Junta os relatorios e mostra na tela
gerarRelatorio :: [LogEntry] -> IO ()
gerarRelatorio logs = do
  putStrLn "\nRelatorio de logs"
  putStrLn ("Total de entradas: " ++ show (length logs))

  putStrLn "\n-- Logs de Erro (logsDeErro) --"
  let erros = logsDeErro logs
  if null erros
    then putStrLn "  Nenhum erro registrado."
    else mapM_ (putStrLn . ("  " ++) . formataEntry) erros

  putStrLn "\n-- Item Mais Movimentado (itemMaisMovimentado) --"
  case itemMaisMovimentado logs of
    Nothing -> putStrLn "  Nenhuma movimentacao registrada."
    Just (iid, n) -> putStrLn ("  " ++ iid ++ " (" ++ show n ++ " operacoes)")
  putStrLn ""

-- Deixa uma linha de log legivel pra mostrar na tela
formataEntry :: LogEntry -> String
formataEntry e = show (acao e) ++ " | " ++ detalhes e ++ " | " ++ show (status e)


-- Parte de I/O e persistencia  (Joao)

arquivoInventario = undefined

arquivoLog = undefined

carregarInventario = undefined

carregarLog = undefined

salvarInventario = undefined

acrescentarLog = undefined

main = undefined

mostrarAjuda = undefined

loop = undefined

lerInt = undefined

processar = undefined

listarInventario = undefined

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
 
addItem = undefined
 
removeItem = undefined
 
updateQty = undefined
 
logEntryFalha = undefined
 
 
-- Relatorios sobre o log - funcoes puras  (Matheus)
 
historicoPorItem = undefined
 
logsDeErro = undefined
 
itemMaisMovimentado = undefined
 
gerarRelatorio = undefined
 
formataEntry = undefined
 
 
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
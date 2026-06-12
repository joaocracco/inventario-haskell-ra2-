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

-- ORGANIZEI AS LOGICAS PRINCIPAIS, FAZER ESSES.
-- Tipos de dados  (Mathias)

-- data Item = ...
-- type Inventario = ...
-- data AcaoLog = ...
-- data StatusLog = ...
-- data LogEntry = ...
-- type ResultadoOperacao = ...


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
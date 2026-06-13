# Sistema de Inventário em Haskell — RA2

Trabalho da disciplina de Programação Funcional. A proposta foi montar um
sistema de inventário que roda no terminal, guarda o estado em disco e
registra tudo que acontece num log de auditoria. O foco do trabalho era
manter a lógica de negócio separada das operações de entrada e saída, então
toda a parte que mexe em arquivo e fala com o usuário fica isolada das funções
puras que calculam o resultado das operações.

## Quem fez

- Instituição: PUCPR
- Disciplina: Programação Funcional
- Professor: Frank Coelho de Alcantara

Integrantes do grupo (em ordem alfabética, com o usuário do GitHub):

- Felippe Matias Cardinot — @sasassa123
- João Victor Cracco — @joaocracco
- Leonardo de Ávila — @Sovhngard
- Matheus Pelissari — @matheus-pelissari

## Onde rodar

Link do ambiente de execução: https://onlinegdb.com/Sy8TRsX7q

Vale lembrar que só são aceitos links do Online GDB ou do Repl.it. Esse link
abre o projeto já com os três arquivos dentro (o `main.hs`, o `Inventario.dat`
e o `Auditoria.log`), então é só clicar em Run que o programa roda sem
precisar mexer em nada.

## O que o sistema faz

Resumindo, ele:

- lê os comandos que o usuário digita no terminal;
- adiciona, remove e atualiza itens do estoque;
- faz toda a lógica em funções puras, sem misturar com I/O;
- salva o estado em `Inventario.dat` depois de cada operação que dá certo;
- vai escrevendo cada tentativa (deu certo ou não) no `Auditoria.log`, sempre
  no fim do arquivo, sem apagar o que já estava lá;
- quando inicia, tenta ler os dois arquivos de volta. Se não achar, começa do
  zero sem quebrar (isso é tratado com `catch`);
- gera uns relatórios em cima do log com o comando `report`.

## Como compilar e rodar

No Online GDB: escolher a linguagem Haskell, colar o conteúdo do `Main.hs` e
clicar em Run. A conversa com o programa acontece pelo terminal.

No Repl.it: criar um Repl de Haskell, jogar o `Main.hs` no lugar do arquivo
principal e dar Run.

Se quiser rodar na própria máquina:

```bash
ghc Main.hs -o inventario
./inventario
```

Não precisa instalar nada além da GHC — os pacotes que a gente usa
(`Data.Map` e `Data.Time`) já vêm junto.

## Comandos

- `add <id> <nome> <qtd> <categoria>` — cadastra um item novo (dá erro se o id já existir)
- `remove <id> <qtd>` — tira uma quantidade do estoque (dá erro se não tiver o suficiente)
- `update <id> <qtd>` — troca a quantidade do item por um valor exato
- `list` — mostra o que tem no estoque agora
- `report` — gera os relatórios em cima do log
- `help` — mostra a ajuda de novo
- `exit` — fecha o programa

Um detalhe: o nome e a categoria têm que ser uma palavra só, porque o programa
separa os campos pelo espaço. Então use algo como `Coca-Cola` em vez de
`Coca Cola`.

Um exemplo rápido de uso:

```
> add p011 Notebook 7 Computadores
OK: id=p011 Adicionado: Notebook, qtd=7
> remove p011 2
OK: id=p011 Removido: 2, restante=5
> remove p011 50
ERRO: Estoque insuficiente para 'p011'. Disponivel: 5, solicitado: 50
> exit
Encerrando. Estado persistido em disco.
```

## Como o código está separado

A parte pura (que não mexe em arquivo nem na tela) tem as funções `addItem`,
`removeItem`, `updateQty` e as de relatório `historicoPorItem`, `logsDeErro`,
`itemMaisMovimentado`. Todas elas só recebem o estado e devolvem um resultado,
usando `Either String ResultadoOperacao` pra avisar quando algo dá errado.

A parte de I/O é onde fica o `main`, o `loop`, o `processar` e as funções que
leem e escrevem os arquivos. É só aqui que acontece `writeFile`, `appendFile`,
`readFile` e os `putStrLn`.

Os tipos (`Item`, `Inventario`, `AcaoLog`, `StatusLog` e `LogEntry`) derivam
`Show` e `Read`, que é o que permite salvar e carregar de volta do disco.

## Divisão do trabalho

- Aluno 1 cuidou dos tipos de dados e de garantir que o `Show`/`Read` funcionasse pra serializar.
- Aluno 2 escreveu a lógica pura das operações (add, remove, update) com a validação de cada caso.
- Aluno 3 ficou com a parte de I/O: o `main`, o loop de comandos e a leitura/escrita dos arquivos.
- Aluno 4 fez as funções de relatório, ligou o comando `report`, cuidou do repositório e escreveu este README com os testes.

## Testes que a gente rodou

A gente executou os três cenários pedidos no enunciado e anotou o que aconteceu.

### Cenário 1 — o estado se mantém entre execuções

Começamos com o programa sem nenhum arquivo de dados. Ele avisou que não achou
o `Inventario.dat` nem o `Auditoria.log` e começou vazio. Aí adicionamos alguns
itens:

```
> add p001 Teclado 10 Perifericos
OK: id=p001 Adicionado: Teclado, qtd=10
> add p002 Mouse 25 Perifericos
OK: id=p002 Adicionado: Mouse, qtd=25
> add p003 Monitor 8 Telas
OK: id=p003 Adicionado: Monitor, qtd=8
```

Fechamos com `exit` e conferimos que os arquivos `Inventario.dat` e
`Auditoria.log` tinham sido criados. Ao abrir o programa de novo, ele mostrou
"Itens carregados: 3" e o `list` trouxe os mesmos itens de volta. Ou seja, o
estado foi salvo e recarregado certinho.

### Cenário 2 — erro de estoque insuficiente

Aqui a ideia era ver o que acontece quando se tenta tirar mais do que tem. Com
o teclado tendo 10 unidades, pedimos pra remover 15:

```
> remove p001 15
ERRO: Estoque insuficiente para 'p001'. Disponivel: 10, solicitado: 15
```

Depois rodamos `list` de novo e o teclado continuava com 10 — a operação que
falha não mexe no `Inventario.dat`. E o `Auditoria.log` ganhou uma linha
marcando essa falha, com o status `Falha`.

### Cenário 3 — relatório de erros

Logo depois do cenário 2, rodamos o `report` pra ver se a falha aparecia no
relatório de erros. Apareceu:

```
Relatorio de logs
Total de entradas: 11
-- Logs de Erro (logsDeErro) --
  Remove | id=p001 Falha na operacao Remove | Falha "Estoque insuficiente para 'p001'. Disponivel: 10, solicitado: 15"
-- Item Mais Movimentado (itemMaisMovimentado) --
  p001 (2 operacoes)
```

A função `logsDeErro` pegou exatamente a tentativa de remoção que tinha
falhado, que era o que a gente queria confirmar.

## Arquivos no repositório

- `Main.hs` — o código todo
- `Inventario.dat` — um estado de exemplo já com 10 itens (atende o mínimo pedido)
- `Auditoria.log` — um log de exemplo, com uma falha incluída pra dar pra testar o `report`
- `README.md` — este arquivo

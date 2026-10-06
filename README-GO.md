# Golang no Neovim (Super IDE)

Ambiente de desenvolvimento moderno em Go configurado com **gopls** (Language Server oficial com suporte a staticcheck, inlay hints e semantic tokens), **conform.nvim** (formatação ultra-rápida com `goimports` e `gofumpt`), depuração integrada via **Delve (dlv)** com **nvim-dap**, testes automatizados visuais com **Neotest (neotest-go)** e um menu unificado de atalhos rápidos sob o prefixo `<leader>G` (ou `Espaço G`). O leader é **Espaço**.

Abra qualquer arquivo `.go`. O **gopls** fornece autocompletion inteligente com documentação embutida, dicas de tipos e parâmetros inline (*inlay hints*), navegação precisa e diagnósticos com checagens estáticas do *staticcheck*. Ao salvar qualquer arquivo, o **conform.nvim** adiciona e organiza automaticamente os imports via `goimports` e formata o código de acordo com o padrão estrito do `gofumpt`.

---

## ⚡ Trabalho Diário (Atalhos Principais)

| Atalho | Comando / Ação | Descrição |
| --- | --- | --- |
| `Espaço G r` ou `Espaço c x` | `:GoRun` | Executa o pacote (`go run .`) ou arquivo atual no terminal |
| `Espaço G b` ou `Espaço c b` | `:GoBuild` | Compila o pacote ou módulo atual (`go build ./...`) |
| `Espaço G t` ou `Espaço t t` | `:GoTest` | Executa o teste unitário mais próximo do cursor |
| `Espaço G f` ou `Espaço t f` | `:GoTestFile` | Executa todos os testes do arquivo atual |
| `Espaço G m` | `:GoModTidy` | Sincroniza e limpa as dependências do `go.mod` (`go mod tidy`) |
| `Espaço G l` | `:GoLint` | Executa o meta-linter `golangci-lint` no projeto |
| `Espaço G c` | `:GoCoverage` | Executa testes e exibe relatório de cobertura (`go test -cover`) |
| `Espaço G d` ou `Espaço d c` | Iniciar Debug | Inicia sessão de depuração com Delve (DAP) |
| `Espaço G i` | `:GoInfo` | Exibe raiz do projeto, módulo ativo, versão do Go e status do gopls |
| `Espaço G ?` | `:GoHelp` | Abre esta documentação de referência |
| `gd` / `gr` | LSP Definition / References | Pula para a definição do símbolo ou lista todas as referências |
| `K` | LSP Hover | Exibe documentação rica, assinaturas e comentários GoDoc |
| `Ctrl-k` em inserção | Signature Help | Mostra a assinatura da função e parâmetros em tempo real |
| `Espaço c a` | Code Action | Ações de código (adicionar tags a structs, preencher campos, extrair) |
| `Espaço c r` | Rename | Renomeia símbolo (função, variável, tipo) em todo o projeto |
| `Espaço c f` | Format | Força a formatação imediata (`goimports` + `gofumpt`) |
| `Espaço c h` | Inlay Hints | Alterna exibição de dicas de tipos e nomes de parâmetros inline |
| `[d` / `]d` | Diagnostic Nav | Navega para o diagnóstico anterior ou próximo |

---

## 🧪 Testes Automatizados (Neotest & Go)

A suíte de testes integrada com o **Neotest** e o adapter **neotest-go** oferece feedback visual imediato e granular:

- **Ícones inline na coluna de sinais (gutter)**: indicam o status de cada teste (`✔` passou, `✖` falhou, `` executando/pendente).
- **Painel em árvore (`Espaço t s`)**: exibe a hierarquia visual completa de pacotes, arquivos, funções de teste e subtestes.
- **Executar teste sob o cursor (`Espaço G t` ou `Espaço t t`)**: roda a função de teste mais próxima, incluindo testes padrão (`TestXxx`) e benchmarks (`BenchmarkXxx`).
- **Executar testes do arquivo (`Espaço G f` ou `Espaço t f`)**: roda toda a suíte de testes do arquivo `*_test.go` aberto.
- **Suporte a Table-Driven Tests**: reconhece subtestes executados com `t.Run(name, ...)` permitindo filtrar e inspecionar cada caso de teste individualmente.
- **Depuração de testes (`Espaço t d`)**: acopla o depurador Delve diretamente ao teste sob o cursor, parando em breakpoints previamente marcados.
- **Visualização de resultados (`Espaço t o` / `Espaço t O`)**: abre uma janela flutuante com a saída detalhada, diffs e logs do teste.

---

## 🪲 Depuração Passo a Passo (DAP & Delve)

O Neovim integra-se nativamente ao **Delve (`dlv`)**, o depurador oficial e mais avançado do ecossistema Go:

1. **Defina seus breakpoints**:
   - `Espaço d b`: Alterna breakpoint na linha atual.
   - `Espaço d B`: Cria um breakpoint condicional (ex: `i == 42` ou `err != nil`).

2. **Inicie a sessão**:
   - Pressione `Espaço d c` ou `Espaço G d` para abrir o seletor de perfis de depuração:
     - **Go: Depurar pacote atual (`.` / `./...`)**: compila e executa o pacote do diretório com Delve.
     - **Go: Depurar arquivo atual**: inicia a depuração isolada do arquivo `.go` aberto.
     - **Go: Depurar teste (cursor ou pacote)**: executa `dlv test` para investigar falhas de testes passo a passo.
     - **Go: Anexar a Processo (Attach)**: conecta ao PID de um executável Go local ou porta de depuração remota (ex: container Docker).

3. **Controle de execução e navegação**:
   - `F10` ou `Espaço d o`: Próxima linha (*Step Over*)
   - `F11` ou `Espaço d i`: Entrar na função (*Step Into*)
   - `F12` ou `Espaço d O`: Sair da função atual (*Step Out*)
   - `F5` ou `Espaço d c`: Continuar execução até o próximo breakpoint (*Continue*)
   - `Espaço d e`: Avaliar variável ou expressão Go sob o cursor ou seleção
   - `Espaço d u`: Alternar visibilidade dos painéis do DAP UI (Scopes, Watches, Stack Trace, Breakpoints)
   - `Espaço d t`: Encerrar a sessão de depuração e fechar os painéis

---

## ✨ Formatação, Linter e Importações

- **Formatação ao Salvar**:
  - `goimports`: Adiciona automaticamente imports necessários da biblioteca padrão ou dependências externas e remove imports órfãos.
  - `gofumpt`: Aplica regras mais estritas que o `gofmt` convencional (formatação de declarações compostas, espaçamento e agrupamento de variáveis), garantindo estilo 100% consistente.
- **Meta-Linter golangci-lint (`:GoLint` ou `Espaço G l`)**:
  - Executa uma bateria completa de linters estáticos (errcheck, gosimple, govet, ineffassign, staticcheck, unused, etc.), apontando possíveis *memory leaks*, erros ignorados ou construções não idiomáticas.
- **Inlay Hints (`Espaço c h`)**:
  - O `gopls` renderiza tipos inferidos de variáveis e nomes de parâmetros de funções diretamente no buffer em texto virtual sutil. Use `Espaço c h` para alternar a exibição a qualquer momento.

---

## 🚀 Snippets Rápidos (LuaSnip)

Digite o gatilho (*trigger*) em modo de inserção e confirme com `Tab`. Para navegar entre os campos do snippet, utilize `Ctrl-l` para avançar e `Ctrl-h` para retroceder.

| Trigger | Descrição | Estrutura Gerada |
| --- | --- | --- |
| `main` | Ponto de entrada | `package main` com função `func main() { ... }` |
| `err` | Verificação de erro | `if err != nil { return err }` |
| `ferr` | Erro com wrapping | `if err != nil { return fmt.Errorf("...: %w", err) }` |
| `fn` | Função padrão | `func name(...) ... { ... }` |
| `meth` | Método com receiver | `func (s *Struct) Method(...) ... { ... }` |
| `st` | Declaração de Struct | `type Name struct { ... }` |
| `iface` | Declaração de Interface | `type Name interface { ... }` |
| `test` | Teste unitário | `func TestName(t *testing.T) { ... }` |
| `table` | Table-Driven Test | Matriz de casos de teste com slice de structs e loop `t.Run` |
| `bench` | Benchmark | `func BenchmarkName(b *testing.B) { ... }` |
| `type` | Tipo / Type Alias | `type Name string` |
| `init` | Função de inicialização | `func init() { ... }` |
| `ctx` | Contexto Go | `ctx context.Context` |
| `go` | Goroutine anônima | `go func() { ... }()` |
| `handler` | Handler HTTP | `func(w http.ResponseWriter, r *http.Request) { ... }` |
| `mw` | Middleware HTTP | `func(next http.Handler) http.Handler { ... }` |

---

## 📦 Requisitos e Ferramentas Recomendadas

1. **Go Toolchain**:
   - Certifique-se de ter o compilador Go instalado no sistema (`go version` no terminal).
2. **Ferramentas gerenciadas pelo Mason**:
   - O **Mason** (`:Mason`) gerencia e instala automaticamente todos os binários essenciais:
     - **gopls**: Language Server oficial mantido pela equipe do Go.
     - **delve (`dlv`)**: Depurador oficial de alta performance para Go.
     - **gofumpt**: Formatador estrito e moderno para código Go.
     - **goimports**: Organizador e resolvedor de pacotes e imports.
     - **golangci-lint**: O meta-linter mais popular e veloz da comunidade Go.
3. **Diagnósticos e Saúde**:
   - `:GoInfo`: Exibe um resumo rápido do ambiente, módulo e status dos LSPs ativos.
   - `:checkhealth vim.lsp`: Inspeciona a integridade e logs do `gopls`.
   - `:ConformInfo`: Verifica a associação dos formatadores ativos (`goimports` e `gofumpt`).

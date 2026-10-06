# Zig no Neovim

Configurado em 28/09/2026 com Zig **0.16.0** instalado pelo `yay`,
ZLS **0.16.0** e CodeLLDB **1.12.3** pelo Mason. Os plugins existentes
continuam sendo usados. O leader é **Espaço**.

Abra um arquivo `.zig` ou `build.zig.zon`. O ZLS oferece autocomplete,
documentação, navegação, renomeação, ações de código, dicas de tipos e
diagnósticos. O `zig fmt` formata ao salvar, inclusive os manifestos ZON.
Os comandos encontram a raiz a partir do arquivo aberto; não é preciso
iniciar o Neovim na raiz do projeto.

## Trabalho diário

| Atalho | Comando / ação |
| --- | --- |
| `Espaço z b` ou `Espaço c b` | `:ZigBuild` — compilar em Debug |
| `Espaço z r` ou `Espaço c x` | `:ZigRun` — executar em terminal interativo |
| `Espaço z t` ou `Espaço c t` | `:ZigTest` — testes do projeto |
| `Espaço z f` | `:ZigTestFile` — testes do arquivo isolado |
| `Espaço z c` | `:ZigCheck` — análise sintática/AST do arquivo |
| `Espaço z s` | `:ZigStop` — interromper tarefa |
| `Espaço z o` | `:ZigOutput` — saída da última tarefa |
| `Espaço z i` | `:ZigInfo` — raiz, compilador e conexão com ZLS |
| `Espaço z ?` | `:ZigHelp` — este guia |
| `gd` / `gr` | Definição / referências |
| `K` | Documentação do símbolo |
| `Ctrl-k` em inserção | Assinatura da função |
| `Espaço c r` / `Espaço c a` | Renomear / ações de código |
| `Espaço c f` | Formatar agora |
| `Espaço c d` / `[d` / `]d` | Detalhes / diagnóstico anterior / próximo |
| `Espaço c h` | Alternar dicas de tipos e parâmetros |

Build e testes rodam em segundo plano e salvam os buffers modificados
dentro da raiz antes de iniciar. Erros com arquivo/linha entram na quickfix:
use `:copen`, `:cnext` e `:cprevious`, ou Enter na lista, para navegar.
A saída completa fica em `:ZigOutput`; `q` fecha o painel.
O terminal de execução aceita entrada; `Esc Esc` sai do modo terminal.

Com `build.zig`, os comandos usam `zig build`, `zig build run` e
`zig build test`, com `-Doptimize=Debug`. Os passos `run` e `test` precisam
existir no projeto — o template de `zig init` já os inclui. Projetos com
um build próprio podem exigir opções adicionais.

Sem `build.zig`, usam `zig build-exe`, `zig run` e `zig test` no arquivo
atual. O executável de `:ZigBuild` fica em `zig-out/bin/<nome>`.
`:ZigTestFile` também usa `zig test` diretamente; módulos que dependem
de imports definidos em `build.zig` devem ser testados com `:ZigTest`.
`:ZigCheck` é uma checagem AST; erros de tipos completos vêm do build/ZLS.

Os comandos aceitam argumentos extras separados por espaços, sem executar
um shell. Exemplos:

```vim
:ZigBuild -Dtarget=x86_64-linux
:ZigBuild check
:ZigRun -- argumento1 argumento2
:ZigTestFile --test-filter nome_do_teste
```

Para argumentos que contêm espaços, use o escape do modo de comandos do
Neovim, por exemplo `nome\ do\ teste`. As aspas de um shell não são interpretadas.

## Autocomplete e snippets

`Ctrl-Space` abre sugestões; `Ctrl-n` / `Ctrl-p` percorrem a lista;
`Tab` aceita e a seta para a esquerda fecha, como na configuração anterior.
`Ctrl-l` expande um snippet ou avança ao próximo campo;
`Ctrl-h` volta ao campo anterior.

Snippets: `std`, `imp`, `fn`, `pfn`, `test`, `struct`, `enum`, `for`,
`fori`, `ifopt`, `defer`, `errdefer` e `alloc`.

## Depuração

1. Marque um breakpoint com `Espaço d b`.
2. Use `Espaço d c` e escolha um perfil Zig:
   - compilar o projeto em Debug e escolher um executável em `zig-out/bin`;
   - escolher um executável já compilado, inclusive por caminho manual;
   - compilar e depurar um arquivo independente;
   - anexar a um processo existente.
3. Use `Espaço d o` para próxima linha, `Espaço d i` para entrar na função
   e `Espaço d O` para sair. `Espaço d c` continua a execução.
4. `Espaço d e` inspeciona um valor; `Espaço d B` cria um breakpoint
   condicional; `Espaço d u` alterna os painéis; `Espaço d t` encerra.

O perfil de arquivo independente compila com `-O Debug -fllvm` e guarda
o binário no cache do Neovim. Projetos usam as escolhas do seu `build.zig`.
Se o backend nativo do Zig não resolver breakpoints, use `.use_llvm = true`
no `b.addExecutable` / `b.addTest` do projeto. O suporte a expressões Zig
no LLDB é limitado; os painéis de variáveis e a navegação por linhas são
as ferramentas principais.

## Manutenção

`zig version` mostra a versão do compilador. `:Mason` gerencia ZLS e
CodeLLDB; `:checkhealth vim.lsp` e `:ConformInfo` ajudam a diagnosticar
problemas. Ao atualizar Zig pelo `yay`, mantenha o ZLS na mesma série
`0.x`; não misture releases estáveis e builds de desenvolvimento.

O ZLS está configurado para compilar ao salvar. Para projetos grandes,
um passo `check` em `build.zig` evita a geração desnecessária do binário
durante a análise. Consulte os exemplos oficiais abaixo antes de adaptar
o build do projeto.

Referências: [compatibilidade Zig/ZLS](https://zigtools.org/zls/install/),
[build ao salvar e passo check](https://zigtools.org/zls/guides/build-on-save/),
[configuração ZLS 0.16](https://raw.githubusercontent.com/zigtools/zls/refs/tags/0.16.0/schema.json),
[CodeLLDB](https://github.com/vadimcn/codelldb/blob/master/MANUAL.md).

Os ajustes ficam em `lua/config/zig.lua`, `ftplugin/`, `snippets/zig.lua`
e nos arquivos existentes de LSP, completion, formatting e DAP em `lua/plugins/`.

Backup anterior a estas alterações:
`~/.local/state/nvim-config-backups/before-zig-20260928-190758/`.

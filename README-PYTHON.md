# Python no Neovim (Super IDE)

Ambiente de desenvolvimento moderno em Python configurado com **Basedpyright** (Language Server aprimorado com inferência estrita de tipos, Generics modernos e Inlay Hints), **Ruff** (Language Server e linter ultra-rápido escrito em Rust), **conform.nvim** (formatação e organização de imports instantâneas com `ruff_format` e `ruff_organize_imports`), **venv-selector.nvim** (seleção e detecção dinâmica de virtualenvs integrados ao Telescope), **debugpy** com **nvim-dap** (depuração completa passo a passo), **Neotest (neotest-python)** (testes automatizados com pytest) e um menu dedicado de atalhos rápidos sob o prefixo `<leader>P` (ou `Espaço P`). O leader é **Espaço**.

Abra qualquer arquivo `.py`. O **Basedpyright** fornece autocompletion inteligente, dicas de tipos e parâmetros inline (*inlay hints*), navegação precisa e verificação estrita de tipagem (PEP 484 / 526 / 695). O **Ruff** analisa o código em tempo real, apontando erros de linting e regras de estilo. Ao salvar qualquer arquivo, o **conform.nvim** organiza automaticamente os imports e formata o código instantaneamente segundo os padrões do Ruff (100% compatível com Black).

---

## ⚡ Trabalho Diário (Atalhos Principais)

| Atalho | Comando / Ação | Descrição |
| --- | --- | --- |
| `Espaço P r` ou `Espaço c x` | `:PythonRun` | Executa o projeto ou arquivo atual no terminal (suporta `uv run` e `.venv`) |
| `Espaço P t` ou `Espaço t t` | `:PythonTest` | Executa o teste unitário mais próximo do cursor via Neotest (pytest) |
| `Espaço P f` ou `Espaço t f` | `:PythonTestFile` | Executa todos os testes do arquivo atual |
| `Espaço P d` ou `Espaço d c` | `:PythonDebug` | Inicia sessão de depuração interativa com debugpy (DAP) |
| `Espaço P v` ou `Espaço c v` | `:PythonVenv` / `:VenvSelect` | Abre o seletor interativo de virtualenvs (uv, poetry, conda, .venv) |
| `Espaço P l` | `:PythonLint` | Executa a verificação completa do linter com `ruff check .` |
| `Espaço P i` | `:PythonInfo` | Exibe raiz do projeto, interpretador ativo, status do LSP e venv |
| `Espaço P ?` | `:PythonHelp` | Abre esta documentação de referência |
| `gd` / `gr` | LSP Definition / References | Pula para a definição do símbolo ou lista referências no projeto |
| `K` | LSP Hover | Exibe documentação rica, assinaturas e docstrings completas |
| `Ctrl-k` em inserção | Signature Help | Mostra a assinatura da função e argumentos em tempo real |
| `Espaço c a` | Code Action | Ações de código e correções automáticas do Ruff e Basedpyright |
| `Espaço c r` | Rename | Renomeia símbolo (função, variável, classe) em todo o projeto |
| `Espaço c f` | Format | Força a formatação e organização de imports imediata |
| `Espaço c h` | Inlay Hints | Alterna exibição de dicas de tipos e parâmetros inline |
| `[d` / `]d` | Diagnostic Nav | Navega para o diagnóstico anterior ou próximo |

---

## 🌐 Gerenciamento de Ambientes Virtuais (Virtualenvs)

O plugin **venv-selector.nvim** integrado ao **Telescope** permite alternar facilmente entre múltiplos ambientes Python:

- **Atalho rápido**: Pressione `Espaço P v` ou `Espaço c v` (ou execute `:VenvSelect`).
- **Suporte automático**: Reconhece diretórios `.venv`, ambientes criados com `uv`, `poetry`, `conda`, `pyenv` e `pipenv`.
- **Sincronização em tempo real**: Ao selecionar um novo ambiente, o **Basedpyright**, o **Ruff** e o **debugpy** são imediatamente redirecionados para o novo interpretador sem necessidade de reiniciar o Neovim.
- **Detecção do Shell**: Se você já tiver ativado um ambiente no terminal antes de abrir o Neovim (`source .venv/bin/activate`), ele será herdado automaticamente.

---

## 🧪 Testes Automatizados (Neotest & pytest)

A suíte de testes integrada com o **Neotest** e o adapter **neotest-python** oferece feedback granular:

- **Ícones inline na coluna de sinais (gutter)**: indicam o status de cada teste (`✔` passou, `✖` falhou, `` executando/pendente).
- **Painel em árvore (`Espaço t s`)**: exibe a hierarquia visual completa de módulos, classes de teste e funções.
- **Executar teste sob o cursor (`Espaço P t` ou `Espaço t t`)**: executa o teste mais próximo com `pytest`.
- **Executar testes do arquivo (`Espaço P f` ou `Espaço t f`)**: roda todos os testes do arquivo `test_*.py` aberto.
- **Depuração de testes (`Espaço t d`)**: conecta o depurador debugpy diretamente ao teste sob o cursor, parando em breakpoints previamente marcados.
- **Visualização de resultados (`Espaço t o` / `Espaço t O`)**: abre uma janela flutuante com saída detalhada, stack traces e logs de erro do pytest.

---

## 🪲 Depuração Passo a Passo (DAP & debugpy)

O Neovim integra-se ao **debugpy**, o mesmo motor de depuração utilizado pelo VS Code:

1. **Defina seus breakpoints**:
   - `Espaço d b`: Alterna breakpoint na linha atual.
   - `Espaço d B`: Cria um breakpoint condicional (ex: `item_count > 10` ou `user is None`).

2. **Inicie a sessão**:
   - Pressione `Espaço d c` ou `Espaço P d`:
     - **Python: Executar arquivo atual**: depura o script aberto utilizando o interpretador do ambiente ativo.
     - **Python: Executar com argumentos**: solicita argumentos via input antes de iniciar.
     - **Python: Anexar a processo remoto (Porta 5678)**: conecta a um container Docker ou serviço remoto ouvindo via debugpy.

3. **Controle de execução**:
   - `F10` ou `Espaço d o`: Próxima linha (*Step Over*)
   - `F11` ou `Espaço d i`: Entrar na função (*Step Into*)
   - `Shift-F11` ou `Espaço d O`: Sair da função atual (*Step Out*)
   - `F5` ou `Espaço d c`: Continuar execução até o próximo breakpoint (*Continue*)
   - `Espaço d e`: Avaliar variável ou expressão sob o cursor ou seleção
   - `Espaço d u`: Alternar visibilidade da interface (Scopes, Watches, Stacks, Breakpoints)
   - `Shift-F5` ou `Espaço d t`: Encerrar a sessão de depuração e fechar os painéis

---

## ✨ Formatação e Linter (Ruff)

- **Formatação ao Salvar**:
  - `ruff_organize_imports`: Ordena imports e agrupa bibliotecas padrão, de terceiros e locais de forma instantânea.
  - `ruff_format`: Formata o código com regras equivalentes ao Black, porém rodando em frações de milissegundos.
- **Linter em Tempo Real**:
  - Diagnósticos inline emitidos pelo Language Server do Ruff.
  - `Espaço P l`: Executa uma varredura completa do projeto no terminal flutuante via `ruff check .`.

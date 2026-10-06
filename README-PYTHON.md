# Python no Neovim (Super IDE)

Configurado para desenvolvimento moderno de **Backend, APIs (FastAPI) e Microsserviços** com **uv**, tipagem estrita via **Basedpyright**, linting/formatação instantânea via **Ruff**, execução de testes visuais com **Neotest (pytest)** e depuração passo a passo com **nvim-dap (debugpy)**. O leader é **Espaço**.

Abra qualquer arquivo `.py`. O Basedpyright fornece autocompletion inteligente, dicas inline (inlay hints de parâmetros e tipos de retorno), navegação precisa e verificação estática. O Ruff formata e organiza imports automaticamente ao salvar no padrão PEP 8.

---

## ⚡ Trabalho Diário (Atalhos Principais)

| Atalho | Comando / Ação | Descrição |
| --- | --- | --- |
| `Espaço p r` ou `Espaço c x` | `:PyRun` | Executa o arquivo atual no terminal com `uv run python` |
| `Espaço p s` | `:PyServer` | Inicia o servidor FastAPI / Uvicorn com hot-reload |
| `Espaço p t` ou `Espaço t t` | `:PyTest` | Executa o teste pytest mais próximo do cursor |
| `Espaço p f` ou `Espaço t f` | `:PyTestFile` | Executa todos os testes do arquivo atual |
| `Espaço t s` | Neotest Summary | Alterna o painel visual em árvore de todos os testes |
| `Espaço t o` | Neotest Output | Abre janela flutuante com a saída e tracebacks do teste |
| `Espaço t d` | Neotest Debug | Depura o teste atual passo a passo com DAP |
| `Espaço p v` ou `Espaço c v` | `:VenvSelect` | Seletor interativo de virtualenvs (uv / .venv) |
| `Espaço p y` ou `Espaço c b` | `:PySync` | Sincroniza dependências do projeto (`uv sync`) |
| `Espaço p i` | `:PyInfo` | Exibe raiz do projeto, interpretador ativo e status do LSP |
| `Espaço p ?` | `:PyHelp` | Abre esta documentação de referência |
| `gd` / `gr` | LSP Definition / References | Pula para definição ou lista referências do símbolo |
| `K` | LSP Hover | Exibe documentação rica e tipagens do Basedpyright |
| `Ctrl-k` em inserção | Signature Help | Mostra assinatura da função e parâmetros em tempo real |
| `Espaço c a` | Code Action | Ações rápidas de código e correções sugeridas pelo Ruff |
| `Espaço c r` | Rename | Renomeia função, variável ou módulo em todo o projeto |
| `Espaço c f` | Format | Força a formatação imediata via Ruff |
| `Espaço c h` | Inlay Hints | Alterna exibição de dicas de tipos e parâmetros inline |
| `[d` / `]d` | Diagnostic Nav | Navega para o diagnóstico anterior ou próximo |

---

## 🧪 Testes Automatizados (Neotest)

A integração com o **Neotest** transforma o Neovim em um ambiente de testes completo:
- **Ícones inline na coluna de sinais (gutter)**: indicam se cada função de teste passou (`✔`), falhou (`✖`) ou está pendente.
- **Painel em árvore (`Espaço t s`)**: navegue pela hierarquia de arquivos de teste, suítes e casos de teste individuais.
- **Depuração de testes (`Espaço t d`)**: execute o teste sob o cursor pausando em breakpoints previamente configurados com `Espaço d b`.
- O runner utiliza automaticamente o interpretador e dependências do ambiente `.venv` gerado pelo `uv`.

---

## 🪲 Depuração Passo a Passo (DAP)

1. Insira breakpoints com `Espaço d b` na linha desejada (ou `Espaço d B` para breakpoint condicional).
2. Pressione `Espaço d c` ou `Espaço p d` para abrir o menu de perfis:
   - **Python: Executar arquivo atual**: executa o arquivo aberto com o depurador acoplado.
   - **Python: Executar arquivo com argumentos**: solicita argumentos de linha de comando antes de iniciar.
   - **Python: Servidor FastAPI / Uvicorn (dev)**: inicia o servidor FastAPI sob o depurador com hot-reload ativo.
   - **Python: Anexar ao Processo (Attach via Porta)**: conecta a um processo remoto ou container na porta informada (padrão `5678`).
3. Navegação durante o debug:
   - `Espaço d o`: Próxima linha (*Step Over*)
   - `Espaço d i`: Entrar na função (*Step Into*)
   - `Espaço d O`: Sair da função (*Step Out*)
   - `Espaço d c`: Continuar execução até o próximo breakpoint
   - `Espaço d e`: Avaliar expressão sob o cursor ou seleção
   - `Espaço d u`: Alternar visibilidade dos painéis do DAP UI (Scopes, Watches, Stacks)
   - `Espaço d t`: Encerrar sessão de debug e fechar os painéis

---

## 📦 Ambientes Virtuais e uv

- O Neovim detecta automaticamente o diretório `.venv` gerado pelo `uv` na raiz do seu projeto.
- Para inspecionar ou trocar manualmente de ambiente, pressione `Espaço p v` para abrir a lista interativa do **venv-selector**.
- O comando `:PySync` (ou `Espaço p y`) roda `uv sync` no terminal integrado para instalar pacotes adicionados ao `pyproject.toml`.

---

## 💡 Autocomplete e Snippets

- `Ctrl-Space`: Abre menu de autocompleções.
- `Tab`: Confirma a sugestão selecionada.
- `Ctrl-l`: Avança para o próximo campo do snippet.
- `Ctrl-h`: Retorna para o campo anterior.
- Snippets incluídos:
  - `main`: Bloco padrão `if __name__ == "__main__":`
  - `fapp`: Inicialização rápida de app FastAPI
  - `get` / `post`: Rotas HTTP com tipagem e retorno
  - `model`: Classe Pydantic `BaseModel`
  - `dc`: Python `@dataclass`
  - `test` / `atest`: Testes pytest síncronos e assíncronos
  - `fixture`: Fixture reutilizável do pytest

---

## 🔧 Manutenção e Diagnósticos

- `:PyInfo`: Resumo rápido do interpretador e LSPs do buffer atual.
- `:checkhealth vim.lsp`: Verifica a saúde dos servidores LSP.
- `:ConformInfo`: Diagnostica formatadores ativos do arquivo.
- `:Mason`: Gerencia as versões instaladas do Basedpyright, Ruff e Debugpy.

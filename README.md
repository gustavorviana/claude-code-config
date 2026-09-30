# Claude Code Configuration

Configurações pessoais e reutilizáveis do [Claude Code](https://claude.com/claude-code), versionadas em Git.

O repositório é a **fonte única** dessas configurações: os diretórios em `~/.claude/` viram links simbólicos que apontam para as pastas daqui. Tudo o que o Claude Code lê ou grava nessas pastas fica, na prática, dentro deste repositório.

```text
claude-code-config/                    ~/.claude/
├── agents/    ◄──────── link ─────────── agents
├── commands/  ◄──────── link ─────────── commands
├── hooks/     ◄──────── link ─────────── hooks
└── skills/    ◄──────── link ─────────── skills
```

## Sumário

- [Estrutura](#estrutura)
- [Instalação](#instalação)
- [Como o setup funciona](#como-o-setup-funciona)
- [Uso no dia a dia](#uso-no-dia-a-dia)
- [Nova máquina](#nova-máquina)
- [Segurança](#segurança)

## Estrutura

```text
.
├── README.md
├── setup.bat        # instalação no Windows
├── setup.sh         # instalação no Linux / macOS
│
├── agents/          # subagents especializados
├── commands/        # comandos personalizados (/comando)
├── hooks/           # scripts usados pelos hooks
└── skills/          # skills e workflows reutilizáveis
```

| Diretório   | Conteúdo                                                        |
| ----------- | --------------------------------------------------------------- |
| `agents/`   | Subagents especializados (arquivos `.md` com frontmatter)       |
| `commands/` | Slash commands personalizados, chamados com `/<nome>`           |
| `hooks/`    | Scripts executados pelos hooks configurados no `settings.json`  |
| `skills/`   | Skills reutilizáveis (uma pasta por skill, com `SKILL.md`)      |

> Cada diretório contém um `.gitkeep` apenas para que o Git versione a pasta enquanto ela estiver vazia. Ele pode ser removido quando a pasta tiver conteúdo.

## Instalação

Clone o repositório e execute o script do seu sistema operacional:

**Windows**

```bat
git clone <repository> claude-code-config
cd claude-code-config
setup.bat
```

> No Windows o script cria **junctions** (`mklink /J`), que não exigem privilégio de administrador. No Linux/macOS são symlinks comuns (`ln -s`).
>
> A pasta `~/.claude/plugins` não é linkada: ela é gerenciada pelo próprio Claude Code (cache, marketplaces e plugins instalados).

**Linux / macOS**

```bash
git clone <repository> claude-code-config
cd claude-code-config
chmod +x setup.sh
./setup.sh
```

Ao final, os links ficam assim:

```text
~/.claude/agents   -> /caminho/para/claude-code-config/agents
~/.claude/commands -> /caminho/para/claude-code-config/commands
~/.claude/hooks    -> /caminho/para/claude-code-config/hooks
~/.claude/skills   -> /caminho/para/claude-code-config/skills
```

> O caminho do repositório fica gravado nos links. Se você mover ou renomear a pasta do repositório, execute o setup novamente.

## Como o setup funciona

O script processa cada diretório individualmente e decide o que fazer com base no estado atual de `~/.claude/<diretório>`:

| Situação em `~/.claude/`         | Ação                                            |
| -------------------------------- | ----------------------------------------------- |
| Já é um link simbólico           | Nada é alterado (`SKIP: já é um link simbólico`) |
| Não existe                       | O link é criado                                 |
| Existe, mas está vazio           | A pasta é removida e substituída pelo link      |
| Existe e tem conteúdo            | O script pergunta o que fazer (veja abaixo)     |

### Diretório com conteúdo

```text
[I] Ignorar esta pasta
[S] Substituir pelo link (APAGA o conteúdo existente)
[C] Copiar conteúdo do Claude -> Repo
[X] Cancelar tudo
```

- **Substituir** pede confirmação digitando `SIM` antes de apagar qualquer coisa.
- **Copiar** mescla o conteúdo de `~/.claude/<diretório>` no repositório. Quando um arquivo já existe nos dois lugares, o conflito é resolvido arquivo a arquivo:

  ```text
  [C] Copiar Claude -> Repo   (sobrescreve o arquivo do repositório)
  [A] Apagar arquivo do Claude
  [S] Pular
  [X] Cancelar
  ```

  Terminada a cópia, a pasta original é removida e substituída pelo link.

> **Dica:** antes de escolher **Copiar**, confira se o repositório está sem alterações pendentes (`git status`). Assim, qualquer arquivo sobrescrito pode ser recuperado com `git diff` / `git restore`.

## Uso no dia a dia

Como `~/.claude/<diretório>` aponta para este repositório, qualquer skill, agent ou command criado ou editado pelo Claude Code já aparece aqui. Basta versionar:

```bash
git status
git add .
git commit -m "Update Claude Code configuration"
git push
```

## Nova máquina

```bash
git clone <repository> claude-code-config
cd claude-code-config

# Windows
setup.bat

# Linux / macOS
./setup.sh
```

O setup recria os links em `~/.claude/` e o ambiente fica igual ao das outras máquinas.

## Segurança

Este repositório é versionado e pode ser enviado para um remoto. **Nunca** coloque aqui:

- API keys, tokens ou senhas
- Credenciais e cookies
- Qualquer arquivo com informações privadas

Configurações que precisem de segredos devem lê-los de **variáveis de ambiente** ou de outro mecanismo apropriado, fora do repositório.

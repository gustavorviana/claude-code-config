---
name: sdd
description: Guia de setup e uso do GitHub Spec Kit (Spec-Driven Development) com Claude Code. Use quando o usuário acionar "sdd", "spec kit", "speckit" ou perguntar como começar/usar SDD em um projeto. Verifica se o CLI `specify` está instalado, detecta se o projeto já usa Spec Kit e entrega o passo a passo adequado (instalar, iniciar projeto novo, adotar em projeto existente com --here, ou usar os comandos /speckit.*).
---

# Objetivo

Levar o usuário a usar o **GitHub Spec Kit** no projeto atual. Nada além disso: não escreva specs, não crie arquivos, não rode `specify init` por conta própria. Diagnostique e entregue o passo a passo certo.

Responda em português, direto, sem explicar conceitos básicos.

# Fluxo

Execute os passos em ordem e pare no primeiro que se aplicar.

## 1. O CLI `specify` está instalado?

Verifique (Bash): `command -v specify || where specify` e, se existir, `specify version`. Verifique também se `uv` existe (`command -v uv || where uv`).

**Se `specify` NÃO estiver instalado**, entregue:

1. Instalar o `uv` (se faltar):
   - Windows (PowerShell): `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`
   - macOS/Linux: `curl -LsSf https://astral.sh/uv/install.sh | sh`
2. Instalar o Spec Kit:
   ```
   uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
   ```
3. Reabrir o terminal e conferir: `specify check`
4. Pedir para acionar o `sdd` de novo depois de instalar.

Pare aqui.

## 2. O projeto já usa Spec Kit?

Considere que usa se existir a pasta `.specify/` na raiz do projeto (normalmente com `.specify/memory/constitution.md`) ou comandos `speckit` em `.claude/commands/`. Liste também `specs/` para ver quais features já existem.

**Se usa**, entregue o passo a passo de uso, indicando em que ponto o projeto está (ex.: constituição ainda é template? há features em `specs/` sem `tasks.md`?):

1. `/speckit.constitution` — princípios do projeto (qualidade, testes, arquitetura). Uma vez por projeto; revisar quando mudar.
2. `/speckit.specify <o que e por quê>` — cria branch e `specs/NNN-feature/spec.md`. Foco em requisitos, não em stack.
3. `/speckit.clarify` — (opcional, recomendado) tira ambiguidades da spec antes do plano.
4. `/speckit.plan <stack e restrições técnicas>` — gera `plan.md`, `research.md`, `data-model.md`, contratos.
5. `/speckit.checklist` — (opcional) checklist de qualidade dos requisitos.
6. `/speckit.tasks` — gera `tasks.md` a partir do plano.
7. `/speckit.analyze` — (opcional, recomendado) consistência entre spec, plano e tarefas.
8. `/speckit.implement` — executa as tarefas.

Diga qual o próximo comando a rodar no estado atual.

## 3. O projeto não usa Spec Kit: está vazio ou tem código?

Olhe a raiz do diretório atual. Considere **vazio** se não houver código-fonte nem arquivos de projeto (ignorar `.git/`, `README`, `LICENSE`, `.gitignore`, `.claude/`).

**Projeto vazio / novo**, entregue:

```
specify init <nome-do-projeto> --ai claude
```
(ou, para iniciar no próprio diretório vazio: `specify init . --ai claude`)

Depois: abrir o Claude Code na pasta do projeto e seguir os comandos `/speckit.*` da seção 2, começando por `/speckit.constitution`.

**Projeto com código**, entregue:

```
specify init --here --ai claude
```
- Rodar na raiz do projeto. Ele avisa que o diretório não está vazio; confirmar (ou usar `--force` para pular a confirmação).
- Commitar ou stashar antes, para revisar o que foi adicionado (`.specify/`, `.claude/commands/`).
- Depois, reiniciar o Claude Code para carregar os novos comandos e seguir a seção 2. Em projeto existente, use `/speckit.constitution` descrevendo as convenções que o código já segue, e `/speckit.specify` para cada mudança nova (não para documentar o sistema inteiro).

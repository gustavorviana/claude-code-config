# Modelos de artefatos SDD

Pontos de partida. Remova seções que não se aplicam em vez de preenchê-las com texto genérico.

## constitution.md

```markdown
# Constituição: <sistema>

## Princípios arquiteturais
- P-001: ...

## Estratégia de testes
- ...

## Convenções
- ...

## Requisitos não funcionais obrigatórios
- NFR-001: ...
```

## spec.md

```markdown
# Spec: <feature/sistema>

Status: rascunho | em revisão | aprovada
Modo: greenfield | brownfield (as-is | to-be)

## Contexto
<problema de negócio e objetivo>

## Atores
| Ator | Descrição | Permissões relevantes |
| ---- | --------- | --------------------- |

## User stories
- US-001: Como <ator>, quero <ação>, para <benefício>.

## Requisitos
### REQ-001: <título>
<descrição do comportamento>
Origem: US-001

Critérios de aceitação:
- AC-001.1: WHEN <evento> THE SYSTEM SHALL <resposta>
- AC-001.2: Given <contexto> When <ação> Then <resultado>

## Regras de negócio
- RN-001: ...

## Casos de borda e erros
- ...

## Requisitos não funcionais
- NFR-001: <métrica verificável>

## Fora de escopo
- ...

## Perguntas em aberto
- [NEEDS CLARIFICATION: ...]
```

## plan.md / design.md

```markdown
# Plano técnico: <feature/sistema>

## Arquitetura
## Modelo de domínio
## Contratos (APIs, eventos)
## Modelo de dados
## Decisões (ADRs)
### DEC-001: <título>
- Contexto:
- Opções consideradas:
- Decisão:
- Consequências:
- Requisitos relacionados: REQ-...
## Riscos
| Risco | Impacto | Mitigação |
| ----- | ------- | --------- |
```

## tasks.md

```markdown
# Tarefas: <feature/sistema>

- [ ] TASK-001: <título>
  - Requisitos: REQ-001 (AC-001.1, AC-001.2)
  - Depende de: —
  - Pronto quando: <critério verificável>
```

## Brownfield: spec as-is (marcação dos itens)

```markdown
- RN-004 [CONFIRMADO] Pedido cancelado não pode ser reaberto. (src/Orders/OrderService.cs:142)
- RN-005 [INFERIDO] Desconto máximo parece ser 30%; validar com o negócio.
- RN-006 [DESCONHECIDO] Regra de arredondamento de impostos.
```

## Brownfield: achados e delta

```markdown
## Achados
- F-001 <inconsistência | duplicação | dívida | possível bug>: ... (origem)

## Delta to-be
| Item | As-is | To-be | Impacto | Migração |
| ---- | ----- | ----- | ------- | -------- |
```

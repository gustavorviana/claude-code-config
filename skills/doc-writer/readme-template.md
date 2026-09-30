# Modelo de README

O README fica no repositório de código e é a porta de entrada do projeto: o que é, como instalar, como começar a usar e onde está a documentação completa. Não segue um tipo Diátaxis único e não substitui a Wiki: referência detalhada, guias longos e ADRs vão para a Wiki, com link.

Inclua **só as seções que se aplicam** ao projeto. Textos `(nota: ...)` são instruções do modelo e não entram no arquivo. Se o idioma escolhido não for PT-BR, traduza também os títulos das seções.

## Regras específicas

- Links para arquivos do repositório são relativos (`docs/x.md`, `src/...`).
- Links para a Wiki usam a URL completa: `https://github.com/<owner>/<repo>/wiki/Nome-Da-Pagina`.
- "Uso" traz um início rápido que roda; o restante aponta para a Wiki, se houver.
- Badges (build, versão do pacote, licença) só se o projeto já tiver CI ou pacote publicado.
- Sumário só se o README tiver mais de 4 seções.

## Modelo

```markdown
# Nome do Projeto

<uma frase: o que é e que problema resolve>

## Sumário
## Sobre
## Tecnologias
## Pré-requisitos
## Instalação
## Uso  (nota: início rápido executável)
## Configuração
## Estrutura do projeto
## Documentação  (nota: link para a Wiki, se houver)
## Contribuição
## Licença
```

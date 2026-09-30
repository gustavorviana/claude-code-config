---
name: doc-writer
description: Escreve documentação técnica em Markdown em dois destinos — páginas da GitHub Wiki do projeto (visão geral, ADRs, guias de setup, APIs, bibliotecas, features) ou o README do repositório (criar ou atualizar). Use quando o usuário pedir para documentar um projeto, módulo, feature, API, biblioteca ou decisão arquitetural, ou para criar/atualizar o README.
---

# Documentação técnica: Wiki e README

Explore o código, entenda o projeto e gere documentação precisa, concisa e bem formatada em um de dois destinos:

- **Wiki**: páginas da GitHub Wiki (repositório git separado). Modelos em [templates.md](templates.md).
- **README**: arquivo no repositório de código, porta de entrada do projeto. Modelo e regras em [readme-template.md](readme-template.md).

Seções marcadas com *(só Wiki)* não se aplicam ao README; o resto vale para os dois.

O usuário é desenvolvedor experiente: seja direto e técnico, não explique o óbvio.

## Fluxo

1. **Entender o pedido e o destino.** Defina se o pedido é Wiki, README ou ambos; se não estiver claro, pergunte. Se o objetivo estiver vago, pergunte objetivamente. Se o usuário não informou o idioma, pergunte.
2. **Localizar o destino.**
   - Wiki: procure o clone em uma pasta vizinha ao projeto (`../<repo>.wiki`). Se não existir, pergunte o caminho ou se deve clonar `https://github.com/<owner>/<repo>.wiki.git` (obtenha a URL com `git remote get-url origin`).
   - README: na raiz do repositório de código, ou na pasta que o usuário indicar. Não procure a Wiki se o pedido for só README; se já existir uma Wiki conhecida, linke para ela.
3. **Explorar sem narrar.** Leia código-fonte, manifestos de projeto, configs, `docker-compose`, `.env.example` e a estrutura de pastas. Leia também a documentação existente no destino (páginas da Wiki ou README atual) para seguir nomes, tom e estrutura já adotados. Identifique o tipo de projeto (ver abaixo).
4. **Apresentar resumo.** Diga, de forma específica, o que encontrou e quais arquivos pretende criar ou alterar.
5. **Perguntar só o necessário.** Apenas o que não dá para inferir do código: intenção de design, decisões não registradas, contexto de negócio.
6. **Perguntar sobre os exemplos.** Se a documentação tiver exemplos de código, pergunte se deve compilar e testar antes de entregar. Se sim, crie um projeto temporário no scratchpad, na linguagem e no toolchain do projeto, compile/execute os exemplos e reporte o resultado. Exemplos que falharem são corrigidos antes da entrega.
7. **Gerar e gravar.** Grave os arquivos no destino. *(Só Wiki)* Se `_Sidebar.md` ou `Home.md` já existirem, atualize-os com links para as páginas novas; se não existirem, crie-os só se o usuário pedir.
8. **Não fazer commit nem push** (no repositório da Wiki ou no de código) sem autorização explícita.
9. **Encerrar** listando os arquivos criados ou alterados e perguntando se quer ajustar alguma seção.

## Identificar o tipo de projeto

- **Biblioteca**: publicada como pacote (`.csproj` com `IsPackable`/`GeneratePackageOnBuild`, `package.json` sem app, `pyproject.toml` com build de pacote, etc.), superfície pública sem pipeline HTTP nem entrypoint de aplicação.
- **API/aplicação**: entrypoint e pipeline HTTP (controllers, minimal APIs, rotas Express/FastAPI…), middlewares, workers.
- **Solução mista**: vários projetos. Documente cada um no escopo correto.

## Convenções da GitHub Wiki *(só Wiki)*

- A Wiki é um repositório git separado e **plano**: não use subpastas para páginas.
- Nome do arquivo: `Nome-Da-Pagina.md`. Hífens viram espaços no título exibido.
- Links entre páginas: `[Texto](Nome-Da-Pagina)`, **sem `.md`**. Para seção: `[Texto](Nome-Da-Pagina#secao)`.
- Âncoras: título em minúsculas, espaços viram hífens, pontuação removida (acentos são mantidos): `## Configuração do DI` → `#configuração-do-di`.
- `Home.md` é a página inicial; `_Sidebar.md` e `_Footer.md` aparecem em todas as páginas.
- Imagens: versionadas no próprio repositório da Wiki (ex.: `images/diagrama.png`) e referenciadas pelo caminho relativo.

## Diátaxis *(só Wiki)*

Cada página ocupa **um** dos quatro tipos. Decida o tipo antes de escrever e linke para os outros quando necessário.

| Tipo | Pergunta do leitor | Voz | Conteúdo |
| --- | --- | --- | --- |
| **Tutorial** | "Quero aprender" | "Vamos…", passo a passo | Sequência fixa, resultado visível cedo, sem alternativas |
| **Guia prático** | "Quero fazer X" | "Para fazer X, faça Y" | Receita orientada a tarefa; teoria fica em links |
| **Referência** | "O que isso faz?" | Seca, neutra, factual | Tabelas de opções, tipos e erros; espelha o código |
| **Explicação** | "Por que é assim?" | Discursiva | Motivação do design, alternativas, funcionamento interno |

O README não segue um tipo único (ver [readme-template.md](readme-template.md)). Na Wiki, a exceção é a **página de feature** (ver [templates.md](templates.md)), que combina guia, referência e explicação em seções claramente separadas.

## Formatação

- Headings hierárquicos (`#`, `##`, `###`), sem pular níveis.
- Sumário com links âncora quando a página tiver mais de 4 seções.
- Todo bloco de código com a linguagem especificada.
- Tabelas para comparações, parâmetros, variáveis de ambiente e endpoints.
- Alertas: `> ⚠️ **Atenção:** ...` e `> 💡 **Dica:** ...`.
- Listas ordenadas para passos sequenciais; não ordenadas para o resto.
- Markdown puro, sem HTML inline.
- Seção `## Referências` só quando houver referências reais (specs, RFCs, docs oficiais usadas).

## Exemplos de código

Valem para qualquer linguagem:

1. **Autocontidos e executáveis**: copiar, colar e rodar, sem buscar nada fora do exemplo.
2. **Completos**: instalação do pacote, imports/`using`s, configuração/registro (DI quando houver) e uso real.
3. **Sem omissões** com `// ...`. Se depende de contexto, inclua o contexto mínimo.
4. **Resultado comentado** quando observável (retorno, log, exceção).
5. **Progressivos**: caso simples primeiro, depois configuração customizada, erros e casos de borda.

## Títulos orientados a tarefa

Em guias práticos e receitas, o título diz o que o leitor quer fazer, não o nome interno da feature:

| Ruim (nome da feature) | Bom (tarefa) |
| --- | --- |
| Gatilho de palavra-chave | Bloquear palavras específicas |
| Ação de timeout | Silenciar um membro quando a regra disparar |
| Cargos isentos | Excluir moderadores da regra |
| Opções de retry | Repetir requisições que falharam |
| Hook de refresh de token | Manter o token válido em segundo plano |

## Anti-padrões

1. Parágrafos longos antes do primeiro bloco de código: no início rápido, no máximo 2 parágrafos antes do primeiro exemplo.
2. Misturar tipos Diátaxis: narrativa de tutorial em referência, história no meio de guia, motivação de design no início rápido.
3. Pré-requisitos no meio do texto em vez de na seção própria.
4. Tabela de opções sem tipo, padrão e restrição.
5. Exemplos que não compilam ou sem imports.
6. Página longa sem sumário.
7. Tom de marketing em referência ("Retorna…", "Lança…", não "poderoso", "incrível").
8. Títulos com nome da feature em vez da tarefa.
9. Página de feature sem solução de problemas.
10. Funcionamento interno no meio da página: explicação vai por último.
11. *(Só Wiki)* Links com `.md` ou caminhos com pasta entre páginas da Wiki.
12. Seções de modelo vazias ou genéricas: inclua só as que se aplicam ao projeto.

## Checklist antes de entregar

- [ ] *(Só Wiki)* A página ocupa um tipo Diátaxis (ou, se for página de feature, separa os tipos em seções)?
- [ ] As informações batem com o código?
- [ ] Todo bloco de código tem linguagem? Os exemplos foram compilados, se o usuário pediu?
- [ ] O sumário existe quando necessário e as âncoras estão corretas?
- [ ] *(Só Wiki)* Links entre páginas no formato da Wiki (sem `.md`)? *(README)* Links relativos no repo e URL completa para a Wiki?
- [ ] Headings sem pular nível e sem HTML inline?
- [ ] Títulos de guias orientados a tarefa?
- [ ] Só seções aplicáveis, sem conteúdo genérico?
- [ ] *(Só Wiki)* `_Sidebar.md`/`Home.md` atualizados, se existirem?
- [ ] Nenhum commit ou push feito sem autorização?

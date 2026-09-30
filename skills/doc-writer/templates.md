# Modelos de página da Wiki

Inclua **só as seções que se aplicam** ao projeto. Textos `(nota: ...)` são instruções do modelo e não entram na página. Os modelos estão em PT-BR; se o idioma escolhido for outro, traduza também os títulos das seções. O modelo do README está em [readme-template.md](readme-template.md).

## Home.md

```markdown
# Nome do Projeto

<uma frase: o que é e que problema resolve>

## Por onde começar
- [Início rápido](Inicio-Rapido)
- [Configuração](Configuracao)

## Guias
- [Como fazer X](Como-Fazer-X)

## Referência
- [API](API)

## Decisões de arquitetura
- [ADR-001: Título](ADR-001-Titulo)
```

## _Sidebar.md

```markdown
**[Início](Home)**

**Primeiros passos**
- [Início rápido](Inicio-Rapido)
- [Configuração](Configuracao)

**Guias**
- [Como fazer X](Como-Fazer-X)

**Referência**
- [API](API)

**Arquitetura**
- [ADRs](ADRs)
```

## ADR (`ADR-NNN-Titulo.md`)

```markdown
# ADR-NNN: Título da decisão

## Status
Proposto | Aceito | Substituído por [ADR-MMM](ADR-MMM-Titulo) | Descontinuado

## Contexto
## Decisão
## Alternativas consideradas
## Consequências
```

## API

```markdown
# Nome do recurso

## Sumário
## URL base
## Autenticação
## Endpoints
### `MÉTODO /caminho`
#### Parâmetros
| Nome | Local | Tipo | Obrigatório | Descrição |
| ---- | ----- | ---- | ----------- | --------- |
#### Corpo da requisição
#### Respostas
| Status | Quando | Corpo |
| ------ | ------ | ----- |
#### Exemplo
## Códigos de erro
```

## Biblioteca

```markdown
# Nome da biblioteca

<uma frase: o que é e que problema resolve>

## Sumário
## Instalação
## Início rápido
## Configuração
### Opções
| Opção | Tipo | Padrão | Restrição | Descrição |
| ----- | ---- | ------ | --------- | --------- |
### Injeção de dependência
## Referência da API
### NomeDaClasse
#### Métodos
## Exemplos
```

### Exemplo completo de biblioteca (.NET com DI)

Estrutura esperada em qualquer exemplo de lib: instalação, imports, registro, uso e resultado. Adapte à linguagem e ao modo de configuração da lib.

```csharp
// dotnet add package MinhaLib
// dotnet add package Microsoft.Extensions.Hosting

using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using MinhaLib;

var builder = Host.CreateApplicationBuilder(args);

builder.Services.AddMinhaLib(options =>
{
    options.Prefixo = "olá";
});

using var host = builder.Build();

var servico = host.Services.GetRequiredService<IMeuServico>();
string resultado = await servico.ProcessarAsync("mundo");

Console.WriteLine(resultado);
// olá, mundo
```

## Página de feature

Para uma feature específica de lib ou SDK. Combina guia, referência e explicação em seções separadas; a ordem é deliberada: início rápido no começo, referência no meio, funcionamento interno no fim.

```markdown
# Nome da feature

> Uma frase: o que é e que problema resolve.

## Sumário
## Quando usar e quando não usar
## Pré-requisitos
## Início rápido  (nota: um exemplo mínimo que roda)
## Conceitos  (nota: 3 a 5 termos usados abaixo)
## Guias
### Como <tarefa específica>
### Como <outra tarefa>
## Referência de configuração  (nota: opção, tipo, padrão, restrição, descrição)
## Eventos e pontos de extensão
## Padrões comuns
## Solução de problemas  (nota: sintoma → causa → correção)
## Como funciona internamente  (nota: opcional para o leitor, sempre por último)
## Veja também
```

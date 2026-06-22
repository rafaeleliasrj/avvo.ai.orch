# Frontend

## Stack

- Next.js 16 com App Router
- React 19 + TypeScript
- Tailwind CSS 4
- shadcn/ui + Radix UI
- React Hook Form + Zod
- TanStack Query
- next-themes

## Estrutura Observada

O frontend esta organizado em `src/` com separacao por rota, feature e infraestrutura compartilhada:

```text
src/
|- app/         # rotas, layouts, route groups e parallel routes
|- components/  # UI compartilhada, com forte uso de components/ui
|- features/    # modulos por dominio com actions, services, hooks, types e components
|- hooks/       # hooks globais de UI e providers leves
|- lib/         # clientes HTTP, env, query keys, mocks e utilitarios base
|- locales/     # dicionarios e registro de i18n
|- providers/   # providers globais, como React Query
|- utils/       # helpers pequenos
\- proxy.ts     # suporte transversal do app
```

Ao gerar codigo para este projeto, preserve a organizacao feature-based observada em `src/features/`.

## Arquitetura

- A aplicacao usa App Router, layouts e route groups do Next.js.
- O padrao preferido para dominio de frontend e `feature-based`.
- Cada feature tende a ter:
  - `services/` para chamadas de API
  - `actions/` para server actions
  - `hooks/` para estado e consumo de dados
  - `types/` para contratos tipados
  - `components/` para UI da feature

## Padrao de Dados e Acesso a API

- Existe separacao entre clientes HTTP em `src/lib/`, inclusive para chamadas autenticadas e publicas.
- O `httpClient` lida com token via cookies e fluxo de refresh.
- Chamada de rede deve ficar em `services/` ou em client libs compartilhados, nao embutida no componente sem necessidade.
- Contratos da API devem ser tipados; nao usar `any`.

## Server Actions

- O projeto ja usa arquivos com `'use server'` para operacoes do lado servidor.
- Actions devem ficar dentro da feature correspondente.
- A action deve validar entrada, chamar service/client e retornar formato previsivel.
- Trate erro de rede de forma controlada, sem vazar excecoes cruas para a UI quando o padrao atual pede fallback ou retorno estruturado.

## Hooks e Estado

- Hooks de dados usam TanStack Query quando a interacao e client-side.
- Query keys centralizadas em `src/lib/query-keys.ts`.
- `useTransition` e estados derivados sao parte do padrao sugerido pelo AGENTS do repositorio.
- Providers globais ficam no layout raiz e em `src/providers/`.

## UI e Componentizacao

- A base visual usa `components/ui` no estilo shadcn/ui.
- Prefira compor componentes existentes antes de criar variacoes paralelas.
- Componentes compartilhados devem ir para `components/`; componentes especificos de dominio devem ficar na feature.
- Mantenha acessibilidade basica consistente com Radix/shadcn e com labels/aria quando aplicavel.

## Convencoes de Projeto

- Use sempre o alias `@/` para imports internos.
- Tipagem estrita esta habilitada no TypeScript; preserve isso.
- O projeto usa `strict: true` e path alias em `tsconfig.json`.
- Evite `any`, coercoes desnecessarias e contratos implícitos.
- Prefira arquivos e simbolos com nomes claros e consistentes com o padrao existente.

## Internacionalizacao

- Existe estrutura de i18n em `src/locales/` com pelo menos `pt-BR`, `en-US` e `es`.
- Strings novas de interface nao devem ser hardcoded se fizerem parte da UI permanente.
- Traducoes devem ser adicionadas aos dicionarios e consumidas pelos hooks/providers existentes.

## Configuracao e Ambiente

- Variaveis publicas como URL da API vivem em `src/lib/env.ts`.
- O projeto suporta modos diferentes de API, incluindo mock mode e modo real.
- Nao hardcode endpoints fora das camadas de `lib/` e `services/`.

## Layout e Providers

- `src/app/layout.tsx` compoe `QueryProvider`, tema, linguagem e toaster.
- Novos providers globais devem entrar no layout apenas quando realmente forem cross-cutting.
- Evite espalhar estado global sem necessidade.

## Estilo de Implementacao

- Componentes client-side devem declarar `'use client'` apenas quando necessario.
- Server-first quando possivel; client components apenas para interatividade, hooks ou browser APIs.
- Separe apresentacao, acesso a dados e transformacao de contrato.
- Quando houver mapeamento entre API e dominio de UI, use tipos/mappers dedicados.

## Ao Adicionar Novas Partes

- Nova tela/rota: `app/` + componentes/feature correspondentes
- Nova integracao com API: tipo + service + action ou hook conforme o fluxo
- Novo formulario: schema Zod + RHF + action/service + feedback visual
- Nova consulta client-side: query key + hook + service
- Novo texto de UI persistente: adicionar em `locales/`

# Backend

## Stack

- .NET 10
- ASP.NET Core Web API
- Entity Framework Core com Npgsql
- MediatR
- FluentValidation
- ASP.NET Core Identity + JWT
- Swagger/OpenAPI

## Estrutura Observada

O backend segue separacao explicita por projetos em `src/`:

```text
src/
|- NautiHub.API/            # entrypoint HTTP, configuracoes, filtros, Swagger
|- NautiHub.Application/    # use cases, features, queries, handlers, models
|- NautiHub.Domain/         # entidades, value objects e contratos de dominio
|- NautiHub.Infrastructure/ # DbContext, mappings EF, repositorios, gateways, identity
|- NautiHub.Core/           # abstractions, utilitarios, recursos compartilhados
\- NautiHub.CrossCutting/   # servicos transversais e integracoes auxiliares
```

Ao gerar codigo para este projeto, preserve essa divisao. Nao misture responsabilidades entre camadas.

## Arquitetura

- O fluxo principal observado e: `Controller -> IMediatorHandler -> Feature/Query Handler -> Domain -> Infrastructure`.
- Controllers nao devem falar com MediatR diretamente; o padrao existente usa `IMediatorHandler`.
- Escrita usa `Features`.
- Leitura usa `Queries`.
- Nao introduza `Commands` como novo padrao se o caso puder seguir a convencao atual de `Feature` e `Query`.

## Padrao da Camada API

- `Program.cs` centraliza bootstrap, localization, auth JWT, Identity, Swagger e registro de servicos.
- URLs sao lowercase.
- A API carrega variaveis de ambiente e usa configuracao por `appsettings` + env vars.
- Swagger e comentarios XML fazem parte do setup padrao.

## Padrao da Camada Application

- Casos de uso ficam organizados por pasta dentro de `UseCases`.
- Cada caso de uso tende a agrupar o request/consulta e o respectivo handler no mesmo contexto.
- Models de entrada e saida ficam em `Models/`, com organizacao por `Requests/` e `Responses/`.
- Validacoes ficam proximas aos requests, em subpastas `Validators`.
- Handlers devem orquestrar; nao concentrar regra complexa neles.

## Padrao da Camada Domain

- O dominio deve permanecer isolado de EF Core e detalhes de infraestrutura.
- Entidades e value objects concentram invariantes e comportamento.
- Evite setters publicos sem necessidade.
- Prefira metodos de dominio que expressem intencao, em vez de mutacao solta de estado.

## Padrao da Camada Infrastructure

- `DatabaseContext` implementa `IUnitOfWork` e centraliza configuracoes globais do modelo.
- Mapeamentos sao aplicados por assembly scan com `ApplyConfigurationsFromAssembly`.
- O projeto usa Fluent API; nao introduza Data Annotations como estrategia principal.
- Repositorios concretos, gateways HTTP, integracoes externas, identidade e persistencia ficam aqui.
- Integracoes externas seguem contratos/interfaces e DTOs dedicados.

## Entity Framework Core

- Use classes de configuracao/mapeamento dedicadas para entidades.
- O contexto aplica convencoes globais para tipos como `string`, `decimal`, `DateTime`, `DateOnly`, `TimeOnly` e `enum`.
- Preserve o uso de migrations em `Infrastructure`.
- Para leitura, prefira consultas eficientes e, quando apropriado, `AsNoTracking()`.
- Evite lazy loading implicito.

## Convencoes de Codigo

- Namespaces, classes, arquivos e simbolos ficam em ingles.
- Comentarios e documentacao podem estar em portugues, seguindo o que o repositorio ja faz.
- Classes e arquivos em `PascalCase`.
- Interfaces com prefixo `I`.
- Campos privados com prefixo `_`.
- O projeto usa nullable reference types habilitado; modele nullability explicitamente.

## Estilo de Implementacao

- Prefira metodos curtos e com responsabilidade unica.
- Use early return para reduzir aninhamento.
- Evite reflection, dinamismo desnecessario e estado global.
- Dependencias devem entrar por abstracoes e DI.
- Mantenha logs estruturados e mensagens de erro explicitas.

## Integracoes e Configuracao

- O backend usa forte configuracao por ambiente e variaveis como conexao Postgres e JWT.
- Nao hardcode segredos, URLs sensiveis ou credenciais.
- Clientes HTTP tipados e servicos externos devem ficar encapsulados na Infrastructure.

## Dominio Principal

O backend representa uma plataforma de marketplace de passeios embarcados. Os blocos principais observados sao:

- autenticacao e perfis de usuario
- embarcacoes
- anuncios de passeio
- reservas
- pagamentos
- reviews
- chat vinculado a reserva

Ao implementar mudancas, preserve a consistencia entre esses fluxos e trate `Booking` e `Payment` como agregados centrais do ciclo operacional.

## Perfis de Usuario

- `BoatOwner`: cadastra e gerencia embarcacoes e anuncios, acompanha reservas e pode interagir com clientes.
- `Customer`: navega por anuncios publicos, realiza reservas, paga e avalia.
- `Admin`: aprova ou rejeita embarcacoes e atua nos fluxos administrativos.

As autorizacoes e regras de acesso devem refletir claramente esse recorte.

## Regras de Embarcacao e Anuncio

- Um dono pode possuir multiplas embarcacoes.
- Cada embarcacao precisa ter identificacao unica.
- O ciclo observado da embarcacao e `Pending -> Approved -> Active`.
- Apenas embarcacoes aprovadas/ativas podem sustentar anuncios publicos.
- O anuncio pode ser `private_tour` ou `group_tour`.
- O tipo do anuncio impacta preco, capacidade, extras e periodos disponiveis.
- O tipo do anuncio nao deve ser tratado como algo livremente mutavel depois de criado se isso quebrar o fluxo existente.

## Criacao Integrada de Listing

O fluxo principal observado cria `Boat` e `Listing` juntos a partir do endpoint de listagem.

Ao tocar esse fluxo:

- considere que o payload integrado pode incluir dados do barco, anuncio, extras e periodos
- preserve consistencia transacional entre os artefatos criados
- mantenha `extras` associados ao fluxo de passeio privativo
- mantenha `periods` associados ao fluxo de passeio coletivo

## Regras de Booking

- `Booking` concentra o agendamento do passeio.
- O agendamento observado fica no proprio booking, com campos como data e horario.
- O sistema deve validar disponibilidade, conflito de agenda e capacidade.
- Em modalidades por assento, o numero de vagas disponiveis e uma regra central.
- O mesmo barco nao deve aceitar reservas sobrepostas em horarios conflitantes.

## Estados de Booking

Os estados observados incluem ao menos:

- `Scheduled`
- `Confirmed`
- `InProgress`
- `Completed`
- `Cancelled`
- `Suspended`

Mudancas nessas transicoes exigem cuidado porque impactam pagamento, aprovacao do proprietario, chat e experiencia no frontend.

## Regras de Pagamento

- O gateway principal observado e Asaas.
- Ha suporte para `PIX`, `boleto`, `credit card` e fluxos especiais de confirmacao manual.
- Pagamento e fortemente acoplado a reserva.
- O sistema aplica split automatico entre plataforma e dono da embarcacao.
- Dados sensiveis de cartao nao devem ser armazenados fora do modelo seguro observado.
- Eventos de webhook atualizam estados financeiros e podem refletir em estados do booking.

## Relacao Booking x Payment

- Antes de criar pagamento, valide a reserva.
- A confirmacao financeira altera o fluxo operacional da reserva.
- Expiracao, estorno e chargeback sao eventos de dominio relevantes, nao apenas detalhes de infraestrutura.

## Reviews e Chat

- `Review` esta vinculada ao fluxo de reserva concluida.
- `ChatMessage` esta vinculado ao contexto da reserva entre cliente e dono.
- Evite modelar chat ou review como fluxo solto sem referencia ao booking quando o caso continuar pertencendo a esse contexto.

## Internacionalizacao e Mensagens de Dominio

- O backend centraliza mensagens em recursos tipados.
- Novas mensagens de negocio devem seguir o padrao de chaves por categoria.
- Nao espalhe strings literais de erro e validacao em handlers ou services.

## Ao Alterar Casos de Uso de Negocio

- valide impacto em estados de `Boat`, `Listing`, `Booking` e `Payment`
- valide impacto em mensagens traduzidas
- valide impacto em busca publica, disponibilidade e aprovacao
- valide se a mudanca exige ajuste em webhook, split, notificacoes ou chat

## Testabilidade

- Estruture codigo para mockar repositorios e servicos por interface.
- Domain deve ser testavel sem dependencias externas.
- Application deve permitir testes de handler com dependencias isoladas.

## Ao Adicionar Novas Partes

- Novo endpoint: API + UseCase + Models + validacao + dependencias registradas
- Nova operacao de escrita: `Feature` + handler
- Nova operacao de leitura: `Query` + handler
- Nova persistencia: interface na camada adequada + implementacao em `Infrastructure`
- Nova entidade: entidade de dominio + mapping/configuration + repository support quando necessario

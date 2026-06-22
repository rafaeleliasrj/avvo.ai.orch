## Backend — API Reference

**Purpose**: .NET 8 monolithic API managing invoicing (NFe/NFCe), fiscal validation, financial operations, and PDV backend for IOB PME. Integrates with SEFAZ, AWS, and external ERP/accounting services.

**Stack**: .NET 8 + EF Core 9 + SQL Server | Docker + Docker Compose | DDD + CQRS + MediatR + Event-Driven Architecture

---

### Service Ports

| Service | Port | Scope |
|---------|------|-------|
| API (Retaguarda + Financeiro) | 9012 | Back-office operations, fiscal management, financial |
| PDV | 9022 | Point-of-sale frontend operations |
| RealTime | 9016 | SignalR real-time notifications and dashboard |

Swagger UI: `:9012/swagger` (Retaguarda + Financeiro), `:9022/swagger` (PDV)

---

### Authentication

- **JWT Bearer** — Hypercube as primary identity provider
- **Delegation JWT** — delegated access (`delegated: true` claim)
- Required headers on every request:
  - `Authorization: Bearer <token>` — JWT issued by Hypercube
  - `X-Empresa-Id: <guid>` — Company/business unit identifier
  - `X-Origem-Id: <string>` — Optional origin identifier (PDV terminal, integration source)

---

### Multi-Tenancy Model

- **TenantId** from `SubscriptionId` JWT claim — scopes all data to the subscription
- **EmpresaId** from `X-Empresa-Id` header — scopes data to the company within the tenant
- All API calls MUST supply both; omitting either results in empty or unauthorized responses

---

### Domain Modules (Bounded Contexts)

| Module | Description |
|--------|-------------|
| Vendas | Sales orders, cart management, checkout |
| Fiscais | NFe/NFCe emission, SEFAZ integration, fiscal validation |
| Financeiro | Accounts payable/receivable, bank reconciliation, financial indicators |
| PDV | Point-of-sale operations, terminal and session management |
| Clientes | Customer management |
| Produtos | Product catalog, pricing, NCM/CEST classification |
| Estoques | Inventory management |
| Fornecedores | Supplier management |
| Transportadoras | Carrier management |
| Condições de Pagamento | Payment terms and conditions |
| Administrativos | Administrative configurations |
| Autorizações | Permission and ACL management |
| Comunicações | Notifications (WhatsApp, Email) |
| Integrações | External ERP/system integrations and exports |

---

### API Response Format

All endpoints return a consistent JSON envelope:

```json
{
  "success": true,
  "data": { ... },
  "errors": [],
  "statusCode": 200
}
```

On validation failure: `success: false`, `errors` contains Portuguese validation messages, `statusCode: 400`.

---

### External Integrations

| System | Purpose |
|--------|---------|
| Hypercube | JWT identity provider — source of auth tokens |
| AWS S3 | Document storage (DANFE PDFs, reports, exports) |
| AWS SQS/SNS | Async event bus — fiscal processing and cross-service messaging |
| SEFAZ | Brazilian tax authority — NFe/NFCe emission and status queries |
| Twilio / Meta WhatsApp | Customer notifications (strategy-selectable) |
| SendGrid | Transactional email via FluentEmail + Razor templates |
| NewRelic | APM monitoring |

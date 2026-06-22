# SPEC: [Feature Name] - MULTI-REPO

## 1. Integration Contract (The Link)
- **Endpoint:** `POST /v1/example`
- **Contract:** `{ "id": UUID, "status": string }`
- **Default error:** `{ "error": { "code": string, "message": string } }`
- **References:**
  - avvo.ai.orch/global/integration-patterns.md
  - avvo.ai.orch/global/naming-conventions.md

## 2. Technical Decisions
- [ ] Chosen alternative and reason.
- [ ] Trade-offs and legacy impacts.

## 3. Changes by Repository

### 📂 REPO-BACKEND
- **Files to modify**
  - [ ] `src/services/logic.php`
    - Details: Implement business rule X following pattern Y found in `src/services/logic.php` line 120.
    - Snippet:
      ```php
      // Minimal example to guide implementation
      ```
  - [ ] `src/controllers/main.php`
    - Details: Create new controller for the endpoint, following the existing controller pattern.
    - Snippet:
      ```pseudo
      // Minimal pseudocode to guide implementation
      ```
- **Files to create**
  - [ ] `src/modules/example/dto.php`
    - Details: DTO for the endpoint, following the existing DTO pattern.
    - Snippet:
      ```php
      // Minimal example to guide implementation
      ```

### 📂 REPO-FRONTEND
- **Files to modify**
  - [ ] `src/api/client.ts`
    - Details: Add function to consume the new endpoint, following the existing API consumption pattern.
    - Snippet:
      ```pseudo
      // Minimal pseudocode to guide implementation
      ```
  - [ ] `src/components/View.tsx`
    - Details: ...
  - [ ] `src/pages/Example.tsx`
    - Details: ...
    - Snippet:
      ```ts
      // Minimal example to guide implementation
      ```

### 📂 ANY-OTHER-REPO
- Same format for the App, if applicable.

## 4. Implementation Iterations
- **Iteration 1 (Backend):** contract + basic rules + minimal tests.
- **Iteration 2 (Frontend):** API client + basic UI.
- **Iteration 3 (App):** ...
...

---

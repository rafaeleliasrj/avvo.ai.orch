# PRD: [Feature Name]

## 1. Objective
- Clear summary of what should be achieved.

## 2. Demand Context
- Trello/Source: [CARD-LINK-OR-ID]
- Stakeholders: [Product, Tech Lead, QA]
- Motivation: [Why is this needed now]

## 3. Scope
- Includes: [Objective list of what will be delivered]
- Excludes: [Out-of-scope items to avoid rework]

## 4. Multi-Repo Impact
- **Backend:** New endpoint/field X required.
- **Frontend:** New screen/component Y consuming field X.
- **App:** Adjustment in screen Z or flow W (if applicable).

## 5. Business Rules & Legacy
- [ ] Legacy golden rules (e.g.: Do not change the Logs table).
- [ ] Mandatory validations (e.g.: status cannot revert to draft).
- [ ] Suggested libraries (e.g.: Use Zod for validation).

## 6. Global Contracts/Standards (Reference)
- [ ] Follow avvo.ai.orch/global/integration-patterns.md.
- [ ] Follow avvo.ai.orch/global/naming-conventions.md.

## 7. Files and Impacted Areas (Research)
- **Backend:** [path/file] - reason for impact.
- **Frontend:** [path/file] - reason for impact.
- **App:** [path/file] - reason for impact.

## 8. Reusable Patterns Found
- [ ] Pattern A: [file/snippet + short explanation].
- [ ] Pattern B: [file/snippet + short explanation].

## 9. External References
- [ ] Official docs: [link]
- [ ] Examples/Articles: [link]

## 10. Relevant Snippets (Research)
- ```ts
  // Short and direct snippet with the main idea
  ```

## 11. Risks, Dependencies, and Notes
- Risks: [technical impacts, deadlines, compatibility]
- Dependencies: [other teams, API ready, releases]

## 12. Success Criteria (Acceptance)
- [ ] Observable result in the product.
- [ ] Does not break existing integration.

# Vigor Broad Fractional Shares — Build Progress

**Overall progress: 23%**  
This is an estimate of the full product scope. **100% means every release gate below is implemented, verified, and ready for production.**

```
[████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 23%
```

## Completed

- [x] Responsive catalogue homepage and seven sector pages.
- [x] Generated illustrations for the listed development concepts.
- [x] Supabase VigorBroad project with sector and development tables, row-level security, and seven sector records.
- [x] Ten agriculture concepts saved as drafts; drafts are not exposed to public catalogue queries.
- [x] Public category pages load only developments whose status is `published`; empty states appear when no reviewed records are public.
- [x] Public development search and alphabetical/newest sorting.
- [x] Seven-tap V logo route to an authenticated catalogue admin page with search, sector/status filters, edit-in-place, and publication readiness checks.
- [x] Admin-only write policies use the protected Supabase `app_metadata.role = admin` claim.
- [x] Private audit trail records development inserts, updates, and deletions; admins can read it.
- [x] Jekyll CI workflow and profile README.

## Work still required to reach 100%

### 1. Regulatory and product scope

- [ ] Confirm the legal entity, countries served, product structure, and whether the offering requires licensing or an authorized partner.
- [ ] Obtain legal and compliance approval for fractional ownership, disclosures, marketing language, investor eligibility, and risk statements.
- [ ] Define the rules for subscriptions, cancellations, transfers, distributions, and investor complaints.

### 2. Admin access and verified catalogue

- [ ] Designate the first administrator account and set its protected Supabase app metadata claim.
- [ ] Verify each development, its owner/operator, location, target, funding figures, risks, and supporting documents.
- [ ] Replace illustrative concepts and figures with approved source data; publish only after review.


### 3. Investor accounts and eligibility

- [ ] Implement account registration, sign-in, recovery, MFA, session controls, and consent records.
- [ ] Select and integrate an identity/KYC provider; handle eligibility, sanctions screening, and verification outcomes.
- [ ] Add investor-owned profiles with strict row-level access rules and data-retention controls.

### 4. Investment and portfolio lifecycle

- [ ] Define the share/unit model, pricing, minimum investment, allocation, and rounding rules.
- [ ] Implement order creation, validation, reservation, cancellation, confirmation, and reconciliation.
- [ ] Build investor portfolio, holdings, transaction history, statements, and status notifications.
- [ ] Add server-side ledger records and an immutable audit history; never rely on browser-calculated balances.

### 5. Market, brokerage, and payments

- [ ] Choose and contract with an authorized broker/market-data provider; confirm permitted use and data licensing.
- [ ] Integrate provider APIs and reconcile orders, fills, holdings, and corporate actions.
- [ ] Choose a payment provider and implement funding, settlement, refunds, failed payments, chargebacks, and reconciliation.
- [ ] Verify that money movement and custody arrangements meet legal and compliance requirements.

### 6. Security, quality, and launch

- [ ] Complete threat modeling, access-control review, dependency review, and independent security testing.
- [ ] Add automated unit, integration, RLS, and end-to-end tests, including negative cross-user access tests.
- [ ] Verify backup/restore, monitoring, alerting, incident response, privacy requests, and production secrets handling.
- [ ] Configure production domain, HTTPS, CI/CD environments, deployment approvals, and post-launch support.
- [ ] Complete a production-readiness review and obtain explicit launch approval.

## Current limitations

The site is a catalogue prototype. It does not onboard investors, take orders, move money, provide brokerage access, or constitute a verified investment offer. The admin page is ready, but no administrator account has been designated yet.

_Progress estimate updated 2026-11-14. The remaining work depends on product decisions, regulated partners, verified project information, and production testing._

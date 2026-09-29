# Database foundation

The public website is static today and has no database connection. This folder defines a PostgreSQL starting point for developments, share offerings, and funding progress. It contains no sample investment data.

## Apply locally

Use a PostgreSQL database you control and review the schema before applying:

```sh
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f database/schema.sql
```

The schema expects UUIDs to be supplied by the application. Amounts use minor currency units (for example, cents for ZAR), never floating-point values.

## Funding progress

Query `offering_funding_progress` for each offering. It counts only settled subscriptions and subtracts settled refunds. Pending or failed payments do not count. The UI should show progress as unavailable until it has a real offering target and verified events; it should not invent a percentage.

## Data boundaries

- `investor_ref` is an opaque UUID from a separately managed identity/KYC provider. Do not put names, ID numbers, identity documents, bank/card information, passwords, or raw payment-provider payloads in this database.
- `provider_reference` should be a non-secret event identifier. Do not store payment credentials or access tokens.
- Keep funding events append-only in production. Restrict writes to a trusted backend and retain an audit trail for provider reconciliation.
- Enforce share availability and prevent overfunding inside a database transaction with row locking. The schema alone does not prevent concurrent purchases from exceeding an offering's remaining shares.
- Use role-based database access, encrypted connections, backups, and a reviewed retention policy before handling real investor activity.

This schema is a technical starting point, not a legal or compliance approval. Production investment operations need review against the actual ownership, payment, reporting, and regulatory model.

-- PostgreSQL starting schema for Vigor Broad property offerings.
-- Amounts are stored in minor currency units (for ZAR, cents) to avoid float rounding.
-- This is a foundation for development and review, not a production investment ledger.
-- Identity and payment credentials must remain with approved external providers.

CREATE TABLE developments (
    id              uuid PRIMARY KEY,
    slug            text NOT NULL UNIQUE,
    name            text NOT NULL,
    summary         text NOT NULL DEFAULT '',
    location_label  text,
    status          text NOT NULL DEFAULT 'draft'
                    CHECK (status IN ('draft', 'published', 'archived')),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE offerings (
    id                  uuid PRIMARY KEY,
    development_id      uuid NOT NULL REFERENCES developments(id),
    name                text NOT NULL,
    currency            char(3) NOT NULL,
    share_price_minor   bigint NOT NULL CHECK (share_price_minor > 0),
    shares_offered      bigint NOT NULL CHECK (shares_offered > 0),
    minimum_shares      bigint NOT NULL CHECK (minimum_shares > 0),
    opens_at            timestamptz,
    closes_at           timestamptz,
    status              text NOT NULL DEFAULT 'preparing'
                        CHECK (status IN ('preparing', 'open', 'paused', 'funded', 'closed')),
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CHECK (minimum_shares <= shares_offered),
    CHECK (closes_at IS NULL OR opens_at IS NULL OR closes_at > opens_at),
    UNIQUE (id, development_id)
);

CREATE INDEX offerings_development_status_idx
    ON offerings (development_id, status);

-- Each row records a funding event after the payment provider reports its outcome.
-- Store only an opaque investor reference; do not store names, identity documents,
-- bank/card details, passwords, or raw provider payloads here.
CREATE TABLE funding_events (
    id                  uuid PRIMARY KEY,
    offering_id         uuid NOT NULL REFERENCES offerings(id),
    investor_ref        uuid NOT NULL,
    event_type          text NOT NULL CHECK (event_type IN ('subscription', 'refund')),
    status              text NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending', 'settled', 'failed', 'voided')),
    amount_minor        bigint NOT NULL CHECK (amount_minor > 0),
    shares              bigint NOT NULL CHECK (shares > 0),
    provider_reference  text UNIQUE,
    settled_at          timestamptz,
    created_at          timestamptz NOT NULL DEFAULT now(),
    CHECK ((status = 'settled') = (settled_at IS NOT NULL))
);

CREATE INDEX funding_events_progress_idx
    ON funding_events (offering_id, status, event_type)
    WHERE status = 'settled';

-- Public progress is based only on settled subscriptions, less settled refunds.
-- Pending, failed, and voided events never count as invested.
CREATE VIEW offering_funding_progress AS
SELECT
    o.id AS offering_id,
    o.development_id,
    o.currency,
    o.share_price_minor * o.shares_offered AS target_minor,
    COALESCE(SUM(
        CASE
            WHEN e.status = 'settled' AND e.event_type = 'subscription' THEN e.amount_minor
            WHEN e.status = 'settled' AND e.event_type = 'refund' THEN -e.amount_minor
            ELSE 0
        END
    ), 0)::bigint AS invested_minor,
    COALESCE(SUM(
        CASE
            WHEN e.status = 'settled' AND e.event_type = 'subscription' THEN e.shares
            WHEN e.status = 'settled' AND e.event_type = 'refund' THEN -e.shares
            ELSE 0
        END
    ), 0)::bigint AS net_shares_funded
FROM offerings o
LEFT JOIN funding_events e ON e.offering_id = o.id
GROUP BY o.id, o.development_id, o.currency, o.share_price_minor, o.shares_offered;

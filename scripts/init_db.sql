CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY,
    supplier_id TEXT NOT NULL,
    total_amount DOUBLE PRECISION NOT NULL,
    items TEXT[] NOT NULL,
    status TEXT NOT NULL,
    version INT NOT NULL DEFAULT 1
);

-- For P3 (Reliability): The Outbox Table
CREATE TABLE IF NOT EXISTS outbox_messages (
    id UUID PRIMARY KEY,
    payload JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed BOOLEAN DEFAULT FALSE
);